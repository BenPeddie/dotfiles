---
name: clickstack-dashboard
description: Create and update ClickStack (HyperDX) dashboards via the ClickHouse Cloud REST API. Use when building new observability dashboards, adding tiles to existing dashboards, programmatically updating dashboard layouts, or automating dashboard management. Triggers on requests to create dashboards, add/modify tiles, update dashboard layouts, manage ClickStack dashboards, or automate HyperDX dashboard configuration.
---

# ClickStack Dashboard Management

> **Important — two separate systems:**
>
> | Task                                 | How to do it                                               |
> | ------------------------------------ | ---------------------------------------------------------- |
> | Query OTEL data (logs, traces, etc.) | `user-mcp-clickhouse` MCP tools (`run_select_query`, etc.) |
> | Create / update ClickStack dashboards | Shell + `curl` against the ClickHouse **Cloud management API** |
>
> These use different base URLs, different credentials, and have nothing in common. Do **not** use `mcp-clickhouse` for dashboard management.

> **HARD LIMITS — read before doing anything:**
>
> 1. **Dashboards only.** You are permitted to list, get, create, and update dashboards. You must not interact with the ClickHouse Cloud service itself (no service restarts, configuration changes, scaling, network rules, or any other service-level operation).
> 2. **No deletes.** You are never allowed to delete a dashboard, regardless of what you are asked. If asked to delete, refuse.

Manage ClickStack / HyperDX dashboards using the ClickHouse Cloud management REST API (`api.clickhouse.cloud`) via Shell + `curl`. The `user-mcp-clickhouse` MCP server is only for running SQL — it has no access to dashboard endpoints.

---

## Top mistakes that ruin formatting (read first)

These are the issues that have actually caused broken-looking dashboards. Internalise them before you write any tile config — they're embedded in every example below for a reason.

1. **Grid is 24 columns wide, not 12.** All polished dashboards use the full 24. Building with 12 squashes everything into the left half. `x + w ≤ 24`.
2. **Markdown header field is `markdown`, not `content`.** `"content": "## ..."` produces a blank tile. Always use `"markdown": "## ..."`.
3. **Markdown headers need `h: 3`, not `h: 1`.** `h: 1` makes the heading invisibly small. Use `h: 3` so the title actually shows.
4. **Number tiles need `numberFormat`** or you get raw floats like `1234567.890123`. See the `numberFormat` section.
5. **Trace fields are PascalCase, log fields are lowercase.** `SpanKind = 'Server'`, `StatusCode = 'Error'`, but `SeverityText = 'error'`. Wrong case → empty results.
6. **Charts and tables need height ≥ 6.** `h: 3` (the old default) produces a sliver. Use `h: 6–7` for line/bar/table tiles, `h: 4` for number KPIs.
7. **Always set `"whereLanguage": "sql"`** on every select item (or `"lucene"` for metric queries that use Lucene). Missing this field silently breaks filters.
8. **`groupBy` is a string, not an array.** `"groupBy": "ServiceName"` — empty string `""` for ungrouped tiles.
9. **`aggFn: "quantile"` requires a sibling `"level"` field** (e.g. `0.95`). There is no `p95` / `p50` shorthand.
10. **Filters apply per `sourceId`.** A single "Environment" filter only affects tiles that use the same source. To filter both logs and traces, add the filter twice — once per source.

---

## How this skill is used

Always paired with the `clickstack-otel` skill in a two-phase workflow:

**Phase 1 — Validate the data** (`clickstack-otel` skill)
Use `run_select_query` via `user-mcp-clickhouse` to run the exact SQL the tile will use. Confirm:

- The table has rows
- Field names exist (e.g. `SpanAttributes['event_type']` is populated for those spans)
- Filter values use the right case (`'Error'` vs `'error'`)
- `groupBy` produces a sensible cardinality (≤ 20 distinct values for charts)

**Phase 2 — Build the dashboard** (this skill)
Translate validated queries into tile configs and POST/PUT them.

```
clickstack-otel skill          clickstack-dashboard skill
───────────────────────        ───────────────────────────
run_select_query  ──────────►  translate to tile config
validate results  ──────────►  POST /dashboards  (create)
check field names ──────────►  PUT  /dashboards/:id  (update)
```

Never construct tiles for queries you haven't first validated against real data. A dashboard full of empty charts is worse than no dashboard.

---

## Prerequisites

All required credentials are already exported in `~/.zshrc`:

| Env var                 | Purpose                                    |
| ----------------------- | ------------------------------------------ |
| `CLICKSTACK_API_KEY`    | Cloud API key ID (Basic Auth username)     |
| `CLICKSTACK_API_SECRET` | Cloud API key secret (Basic Auth password) |
| `CLICKSTACK_ORG_ID`     | ClickHouse Cloud organisation UUID         |
| `CLICKSTACK_SERVICE_ID` | ClickHouse Cloud service UUID              |

These are **Cloud management API credentials** — entirely separate from the `CLICKHOUSE_PASSWORD` SQL credential used by `mcp-clickhouse`.

Set the base URL once per shell session:

```bash
source ~/.zshrc
BASE="https://api.clickhouse.cloud/v1/organizations/${CLICKSTACK_ORG_ID}/services/${CLICKSTACK_SERVICE_ID}/clickstack/dashboards"
```

All `curl` calls authenticate with `-u "${CLICKSTACK_API_KEY}:${CLICKSTACK_API_SECRET}"`.

> **Shell gotcha:** new shells the agent spawns don't inherit env vars. Re-`source ~/.zshrc` and re-set `BASE` at the start of every shell command, or chain everything in one command with `&&`.

---

## API Endpoints

| Operation        | Method | Path                                        |
| ---------------- | ------ | ------------------------------------------- |
| List dashboards  | GET    | `/v1/…/clickstack/dashboards`               |
| Create dashboard | POST   | `/v1/…/clickstack/dashboards`               |
| Get dashboard    | GET    | `/v1/…/clickstack/dashboards/{dashboardId}` |
| Update dashboard | PUT    | `/v1/…/clickstack/dashboards/{dashboardId}` |

## Workflow (always in this order)

1. **List** dashboards to find IDs / check for duplicates
2. **Get** the target dashboard (PUT requires the full tile list)
3. **Create** or **Update** with the complete payload
4. **Verify** by fetching it back and inspecting `tiles | length` and a sample tile

---

## Discover source IDs first

Every non-markdown tile needs a `sourceId`. There are typically 3 in a service:

| Source kind | What's in it                               | How to get the ID                                                            |
| ----------- | ------------------------------------------ | ---------------------------------------------------------------------------- |
| Traces      | `Spans` — `SpanName`, `SpanAttributes`, `Duration`, `SpanKind`, `StatusCode` | GET an existing tile that queries spans (e.g. uses `SpanName`)               |
| Logs        | `Logs` — `Body`, `SeverityText`, `LogAttributes`                              | GET an existing tile that queries logs (e.g. uses `SeverityText`)            |
| Metrics     | OTEL metrics — `MetricName`, `Value`, `MetricType`                            | GET an existing tile that uses `metricName` / `metricType` in its select item |

Find them once and reuse:

```bash
curl -s -u "${CLICKSTACK_API_KEY}:${CLICKSTACK_API_SECRET}" "$BASE/<known-dashboard-id>" \
  | jq -r '.result.tiles[] | select(.config.sourceId) | {name, sourceId: .config.sourceId, hint: (.config.select[0].where // "")}'
```

Then pin them at the top of your script:

```bash
TRACES_SOURCE="69aae07b5f633bded2c0c3bf"
LOGS_SOURCE="69aad949ca85c2ede1145270"
METRICS_SOURCE="69aae140aa68c6cad07ec45f"
```

---

## OTEL field cheat sheet

The most common cause of empty tiles is wrong field names or wrong case. Burn these into your config before writing tiles.

### Trace fields (traces source) — PascalCase values

| Field                        | Example                                  | Notes                                                  |
| ---------------------------- | ---------------------------------------- | ------------------------------------------------------ |
| `ServiceName`                | `'notifications'`                        | The OTEL `service.name` resource attribute             |
| `SpanName`                   | `'GET /admin/notifications'`             | Often the operation name; case-sensitive               |
| `SpanKind`                   | `'Server'`, `'Client'`, `'Internal'`     | **PascalCase, not `'SERVER'`**                          |
| `StatusCode`                 | `'Error'`, `'Ok'`, `'Unset'`             | **PascalCase. This is the trace error signal.**         |
| `Duration`                   | nanoseconds — divide by `1000000` for ms |                                                        |
| `SpanAttributes['key']`      | `SpanAttributes['http.response.status_code']` | Map access with single quotes around the key            |
| `ResourceAttributes['key']`  | `ResourceAttributes['deployment.environment']` | Resource-level attributes (env, k8s.node.name, etc.)    |

### Log fields (logs source) — lowercase severities

| Field                       | Example                                | Notes                                                  |
| --------------------------- | -------------------------------------- | ------------------------------------------------------ |
| `ServiceName`               | `'notifications'`                      | Same as traces                                         |
| `SeverityText`              | `'error'`, `'warn'`, `'info'`, `'fatal'` | **lowercase. Different from trace `StatusCode`.**       |
| `Body`                      | The log message string                  | Group by `Body` for top-error tables                   |
| `LogAttributes['key']`      | `LogAttributes['notification_type']`   | Map access; values are always strings                  |
| `ResourceAttributes['key']` | same as traces                          |                                                        |

### Metric fields (metrics source)

| Field                       | Notes                                                                              |
| --------------------------- | ---------------------------------------------------------------------------------- |
| `MetricName`                | Set via the `metricName` select field, **not** in `where`                          |
| `Value`                     | Use as `valueExpression` for `avg`/`sum`/`min`/`max`/`quantile`                    |
| `Attributes['key']`         | Per-datapoint attributes                                                           |
| `ResourceAttributes['key']` | k8s/host/service resource attributes — most dashboard groupings live here          |

### Casting attribute values

Map values are always strings. To aggregate numerically:

```sql
toInt64OrZero(LogAttributes['reminder_count'])
toFloat64OrZero(SpanAttributes['response_time_ms'])
```

Use these as the `valueExpression` for `sum` / `avg` / `quantile` aggregations on attribute values.

---

## Get / List / Create / Update

### List

```bash
curl -s -u "${CLICKSTACK_API_KEY}:${CLICKSTACK_API_SECRET}" "$BASE" | jq '.result[] | {id, name}'
```

### Get (always before update)

```bash
DASHBOARD_ID="<uuid>"
EXISTING=$(curl -s -u "${CLICKSTACK_API_KEY}:${CLICKSTACK_API_SECRET}" "$BASE/$DASHBOARD_ID")
echo "$EXISTING" | jq '.result | {name, tags, tileCount: (.tiles | length)}'
```

### Create

```bash
curl -s -u "${CLICKSTACK_API_KEY}:${CLICKSTACK_API_SECRET}" -X POST "$BASE" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My New Dashboard",
    "tags": ["observability"],
    "tiles": []
  }' | jq '{id: .result.id, name: .result.name}'
```

A dashboard with no tiles is valid — useful as a placeholder you fill in via PUT.

### Update

```bash
curl -s -u "${CLICKSTACK_API_KEY}:${CLICKSTACK_API_SECRET}" -X PUT "$BASE/$DASHBOARD_ID" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" | jq '{id: .result.id, name: .result.name, tileCount: (.result.tiles | length)}'
```

> **Critical:** PUT replaces the **complete** tile list. Any tile omitted is deleted. Tiles are matched by their `id` field — preserve existing IDs to keep tiles stable.

---

## Dashboard JSON structure

```json
{
  "name": "string (required)",
  "tags": ["string"],
  "tiles": [ /* ClickStackTileInput */ ],
  "filters": [ /* ClickStackFilterInput */ ],
  "savedQuery": null,
  "savedQueryLanguage": null,
  "savedFilterValues": []
}
```

---

## Tile structure

```json
{
  "id": "optional-uuid-for-updates",
  "name": "Tile Title",
  "x": 0, "y": 0, "w": 6, "h": 7,
  "config": {
    "displayType": "line",
    "sourceId": "<source-uuid>",
    "asRatio": false,
    "alignDateRangeToGranularity": true,
    "fillNulls": true,
    "groupBy": "",
    "select": [
      {
        "aggFn": "count",
        "valueExpression": "",
        "alias": "Requests",
        "where": "ServiceName = 'notifications' AND SpanKind = 'Server'",
        "whereLanguage": "sql"
      }
    ]
  }
}
```

### Required `config` fields by `displayType`

| `displayType`  | Required `config` keys                                                                                            | Notes                                          |
| -------------- | ----------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| `line`         | `sourceId`, `select`, `groupBy`, `asRatio`, `alignDateRangeToGranularity`, `fillNulls`                            | Time series; supports multi-series via `select` |
| `stacked_bar`  | same as `line`                                                                                                    | Use for grouped categorical comparisons         |
| `number`       | `sourceId`, `select`. Add `numberFormat` for any non-trivial number.                                              | Single KPI                                     |
| `table`        | `sourceId`, `select`, `groupBy`, `asRatio`                                                                        | Top-N by dimension                             |
| `markdown`     | `markdown` (the body — **not** `content`)                                                                          | No `select` / `sourceId`                       |
| `pie`          | `sourceId`, `select`, `groupBy`                                                                                   | Use sparingly — table is usually clearer       |
| `search`       | `sourceId`, optional `where`                                                                                      | Raw event list                                 |

### Aggregation functions (`aggFn`)

| `aggFn`          | Description                          | Notes                                                                |
| ---------------- | ------------------------------------ | -------------------------------------------------------------------- |
| `count`          | Row count                            | `valueExpression: ""`                                                |
| `sum`            | Sum of `valueExpression`             |                                                                      |
| `avg`            | Average of `valueExpression`         |                                                                      |
| `min` / `max`    | Min / max of `valueExpression`       |                                                                      |
| `quantile`       | Percentile of `valueExpression`      | **Must include `"level": 0.95` (or 0.50, 0.99, etc.). No `p95`.**     |
| `count_distinct` | Distinct values of `valueExpression` |                                                                      |

### `numberFormat` (for `number` and `line` tiles showing magnitudes)

```json
"numberFormat": {
  "output": "number",
  "mantissa": 0,
  "thousandSeparated": true
}
```

| Field               | Values                                                      | Use                                                  |
| ------------------- | ----------------------------------------------------------- | ---------------------------------------------------- |
| `output`            | `"number"`, `"byte"`, `"percent"`                            | What units the value represents                      |
| `mantissa`          | integer 0–3                                                  | Decimal places                                       |
| `thousandSeparated` | bool                                                         | `true` for counts (e.g. `1,234,567`)                  |
| `factor`            | number                                                       | Multiplier (rarely needed)                           |
| `average`           | bool                                                         | Show as average across the time range                |

Common patterns:

```json
// Counts: 12,345
{"output": "number", "mantissa": 0, "thousandSeparated": true}

// Latency in ms: 123.45
{"output": "number", "mantissa": 2}

// Memory: 4.2 GB
{"output": "byte", "mantissa": 1}

// CPU: 73.5 %
{"output": "percent", "mantissa": 1}
```

---

## Layout cookbook (24-column grid)

The grid is **24 columns wide** with arbitrary row height. `x + w` must be `≤ 24`. Stack rows by incrementing `y` by the height of the tallest tile in the row above.

### Standard heights

| Tile type                          | Recommended `h` |
| ---------------------------------- | --------------- |
| Markdown section header            | `3`             |
| Number KPI                         | `4`             |
| Line / stacked_bar / pie / table   | `7`             |
| Large detail chart                 | `9`–`12`        |

### Pattern 1 — Full-width header + 6-up KPI strip

```text
│ ## Service Health                  (w:24, h:3)                                         │
│ KPI │ KPI │ KPI │ KPI │ KPI │ KPI                                                      │
│ 4   │ 4   │ 4   │ 4   │ 4   │ 4                                                       │
```

```json
[
  {"x": 0,  "y": 0, "w": 24, "h": 3, "name": "", "config": {"displayType": "markdown", "markdown": "## Service Health"}},
  {"x": 0,  "y": 3, "w": 4,  "h": 4, "name": "Requests", "config": { /* number tile */ }},
  {"x": 4,  "y": 3, "w": 4,  "h": 4, "name": "Errors",   "config": { /* number tile */ }},
  {"x": 8,  "y": 3, "w": 4,  "h": 4, "name": "P95 ms",   "config": { /* number tile */ }},
  {"x": 12, "y": 3, "w": 4,  "h": 4, "name": "Sent",     "config": { /* number tile */ }},
  {"x": 16, "y": 3, "w": 4,  "h": 4, "name": "Scheduled","config": { /* number tile */ }},
  {"x": 20, "y": 3, "w": 4,  "h": 4, "name": "Inflight", "config": { /* number tile */ }}
]
```

### Pattern 2 — Two columns of related sections

Half-width markdown headers act as column dividers. Charts go below in matching halves.

```text
│ ## HTTP API     (w:12, h:3)        │ ## SQS Consumer (w:12, h:3)        │
│ Chart (12x7)                       │ Chart (12x7)                       │
```

```json
[
  {"x": 0,  "y": 7,  "w": 12, "h": 3, "config": {"displayType": "markdown", "markdown": "## HTTP API"}},
  {"x": 12, "y": 7,  "w": 12, "h": 3, "config": {"displayType": "markdown", "markdown": "## SQS Consumer"}},
  {"x": 0,  "y": 10, "w": 12, "h": 7, "config": { /* HTTP chart */ }},
  {"x": 12, "y": 10, "w": 12, "h": 7, "config": { /* SQS chart */ }}
]
```

### Pattern 3 — Two charts side-by-side within a column

Inside a 12-wide column, pair two `6x7` charts:

```text
│ Chart A (6x7) │ Chart B (6x7) │
```

### Pattern 4 — Detail table beside summary chart

```text
│ Trend chart (12x7) │ Top-N table (12x7) │
```

---

## Tile recipes (copy-paste ready)

All examples assume `$TRACES_SOURCE` / `$LOGS_SOURCE` / `$METRICS_SOURCE` are set.

### Markdown section header

```json
{
  "x": 0, "y": 0, "w": 24, "h": 3,
  "name": "",
  "config": {
    "displayType": "markdown",
    "markdown": "## Service Health"
  }
}
```

### Number KPI — count

```json
{
  "x": 0, "y": 3, "w": 4, "h": 4,
  "name": "HTTP Requests",
  "config": {
    "displayType": "number",
    "sourceId": "<traces-source>",
    "select": [
      {
        "aggFn": "count",
        "valueExpression": "",
        "alias": "Requests",
        "where": "ServiceName = 'notifications' AND SpanKind = 'Server'",
        "whereLanguage": "sql"
      }
    ],
    "numberFormat": {"output": "number", "mantissa": 0, "thousandSeparated": true}
  }
}
```

### Number KPI — P95 latency in ms

```json
{
  "x": 8, "y": 10, "w": 5, "h": 4,
  "name": "P95 Email History (ms)",
  "config": {
    "displayType": "number",
    "sourceId": "<traces-source>",
    "select": [
      {
        "aggFn": "quantile",
        "level": 0.95,
        "valueExpression": "Duration / 1000000",
        "alias": "P95 ms",
        "where": "ServiceName = 'notifications' AND SpanName = 'GET /_internal/email-history'",
        "whereLanguage": "sql"
      }
    ],
    "numberFormat": {"output": "number", "mantissa": 2, "thousandSeparated": true}
  }
}
```

### Line — error rate by service

```json
{
  "x": 0, "y": 10, "w": 12, "h": 7,
  "name": "Error Spans Over Time",
  "config": {
    "displayType": "line",
    "sourceId": "<traces-source>",
    "asRatio": false,
    "alignDateRangeToGranularity": true,
    "fillNulls": true,
    "groupBy": "ServiceName",
    "select": [
      {
        "aggFn": "count",
        "valueExpression": "",
        "alias": "Errors",
        "where": "StatusCode = 'Error'",
        "whereLanguage": "sql"
      }
    ]
  }
}
```

### Stacked bar — events by attribute dimension

```json
{
  "x": 13, "y": 10, "w": 6, "h": 7,
  "name": "Messages by Event Type",
  "config": {
    "displayType": "stacked_bar",
    "sourceId": "<traces-source>",
    "asRatio": false,
    "alignDateRangeToGranularity": true,
    "fillNulls": true,
    "groupBy": "SpanAttributes['event_type']",
    "select": [
      {
        "aggFn": "count",
        "valueExpression": "",
        "alias": "Messages",
        "where": "ServiceName = 'notifications' AND SpanName = 'notifications.process_message'",
        "whereLanguage": "sql"
      }
    ]
  }
}
```

### Table — top error messages

```json
{
  "x": 0, "y": 44, "w": 12, "h": 7,
  "name": "Top Error Messages",
  "config": {
    "displayType": "table",
    "sourceId": "<logs-source>",
    "asRatio": false,
    "groupBy": "Body",
    "select": [
      {
        "aggFn": "count",
        "valueExpression": "",
        "alias": "Count",
        "where": "ServiceName = 'notifications' AND SeverityText = 'error'",
        "whereLanguage": "sql"
      }
    ]
  }
}
```

### Multi-series line — used vs limit vs target

A single tile can plot multiple series by adding multiple `select` items:

```json
{
  "x": 0, "y": 4, "w": 12, "h": 7,
  "name": "Memory: Used vs Limit vs GC Target",
  "config": {
    "displayType": "line",
    "sourceId": "<metrics-source>",
    "asRatio": false,
    "alignDateRangeToGranularity": true,
    "fillNulls": true,
    "select": [
      {"aggFn": "sum", "alias": "used",      "metricName": "go.memory.used",     "metricType": "sum", "valueExpression": "", "where": "", "whereLanguage": "lucene"},
      {"aggFn": "avg", "alias": "limit",     "metricName": "go.memory.limit",    "metricType": "sum", "valueExpression": "", "where": "", "whereLanguage": "lucene"},
      {"aggFn": "avg", "alias": "gc target", "metricName": "go.memory.gc.goal",  "metricType": "sum", "valueExpression": "", "where": "", "whereLanguage": "lucene"}
    ],
    "numberFormat": {"output": "byte", "mantissa": 1}
  }
}
```

### Metric tile (gauge with k8s dimension)

Metric source select items **must** specify `metricName` and `metricType` (lowercase: `gauge`, `sum`, `histogram`, `summary`, `exponential histogram`). Don't put `MetricName = '...'` in the `where` clause.

```json
{
  "x": 0, "y": 0, "w": 6, "h": 7,
  "name": "Node CPU Utilisation",
  "config": {
    "displayType": "line",
    "sourceId": "<metrics-source>",
    "asRatio": false,
    "alignDateRangeToGranularity": true,
    "fillNulls": true,
    "groupBy": "ResourceAttributes['k8s.node.name']",
    "select": [
      {
        "aggFn": "avg",
        "valueExpression": "Value",
        "alias": "CPU",
        "metricName": "k8s.node.cpu.utilization",
        "metricType": "gauge",
        "where": "",
        "whereLanguage": "sql"
      }
    ],
    "numberFormat": {"output": "percent", "mantissa": 1}
  }
}
```

You can still add a `where` clause to narrow by `ResourceAttributes` dimensions (e.g. `ResourceAttributes['deployment.environment'] = 'prod'`).

---

## Filters

Dashboard-level filters add interactive narrowing across tiles. They apply **only to tiles that share the same `sourceId`**, so to filter both logs and traces you need one filter per source.

```json
"filters": [
  {
    "type": "QUERY_EXPRESSION",
    "name": "Environment",
    "expression": "ResourceAttributes['deployment.environment']",
    "sourceId": "<traces-source>"
  },
  {
    "type": "QUERY_EXPRESSION",
    "name": "Environment",
    "expression": "ResourceAttributes['deployment.environment']",
    "sourceId": "<logs-source>"
  }
]
```

`type` is always `"QUERY_EXPRESSION"` (not `"text"` / `"select"`).

---

## End-to-end example

A minimal but properly-formatted dashboard you can adapt directly.

```bash
source ~/.zshrc
BASE="https://api.clickhouse.cloud/v1/organizations/${CLICKSTACK_ORG_ID}/services/${CLICKSTACK_SERVICE_ID}/clickstack/dashboards"
TRACES_SOURCE="69aae07b5f633bded2c0c3bf"
LOGS_SOURCE="69aad949ca85c2ede1145270"

PAYLOAD=$(jq -n --arg traces "$TRACES_SOURCE" --arg logs "$LOGS_SOURCE" '{
  name: "Service Health (example)",
  tags: ["observability"],
  tiles: [
    {x:0,  y:0, w:24, h:3, name:"", config:{displayType:"markdown", markdown:"## Service Health"}},
    {x:0,  y:3, w:6,  h:4, name:"Requests", config:{
      displayType:"number", sourceId:$traces,
      select:[{aggFn:"count", valueExpression:"", alias:"Requests",
               where:"ServiceName = '\''notifications'\'' AND SpanKind = '\''Server'\''",
               whereLanguage:"sql"}],
      numberFormat:{output:"number", mantissa:0, thousandSeparated:true}
    }},
    {x:6,  y:3, w:6,  h:4, name:"Trace Errors", config:{
      displayType:"number", sourceId:$traces,
      select:[{aggFn:"count", valueExpression:"", alias:"Errors",
               where:"ServiceName = '\''notifications'\'' AND StatusCode = '\''Error'\''",
               whereLanguage:"sql"}],
      numberFormat:{output:"number", mantissa:0, thousandSeparated:true}
    }},
    {x:12, y:3, w:6,  h:4, name:"Log Errors", config:{
      displayType:"number", sourceId:$logs,
      select:[{aggFn:"count", valueExpression:"", alias:"Errors",
               where:"ServiceName = '\''notifications'\'' AND SeverityText = '\''error'\''",
               whereLanguage:"sql"}],
      numberFormat:{output:"number", mantissa:0, thousandSeparated:true}
    }},
    {x:18, y:3, w:6,  h:4, name:"P95 Latency (ms)", config:{
      displayType:"number", sourceId:$traces,
      select:[{aggFn:"quantile", level:0.95, valueExpression:"Duration / 1000000",
               alias:"P95 ms",
               where:"ServiceName = '\''notifications'\'' AND SpanKind = '\''Server'\''",
               whereLanguage:"sql"}],
      numberFormat:{output:"number", mantissa:2, thousandSeparated:true}
    }},
    {x:0,  y:7, w:12, h:7, name:"Errors Over Time", config:{
      displayType:"line", sourceId:$traces,
      asRatio:false, alignDateRangeToGranularity:true, fillNulls:true,
      groupBy:"SpanName",
      select:[{aggFn:"count", valueExpression:"", alias:"Errors",
               where:"ServiceName = '\''notifications'\'' AND StatusCode = '\''Error'\''",
               whereLanguage:"sql"}]
    }},
    {x:12, y:7, w:12, h:7, name:"Top Error Messages", config:{
      displayType:"table", sourceId:$logs,
      asRatio:false, groupBy:"Body",
      select:[{aggFn:"count", valueExpression:"", alias:"Count",
               where:"ServiceName = '\''notifications'\'' AND SeverityText = '\''error'\''",
               whereLanguage:"sql"}]
    }}
  ],
  filters: [
    {type:"QUERY_EXPRESSION", name:"Environment",
     expression:"ResourceAttributes['\''deployment.environment'\'']", sourceId:$traces},
    {type:"QUERY_EXPRESSION", name:"Environment",
     expression:"ResourceAttributes['\''deployment.environment'\'']", sourceId:$logs}
  ]
}')

curl -s -u "${CLICKSTACK_API_KEY}:${CLICKSTACK_API_SECRET}" -X POST "$BASE" \
  -H "Content-Type: application/json" -d "$PAYLOAD" \
  | jq '{id: .result.id, name: .result.name, tileCount: (.result.tiles | length)}'
```

---

## Update workflow — append a tile preserving existing ones

```bash
EXISTING=$(curl -s -u "${CLICKSTACK_API_KEY}:${CLICKSTACK_API_SECRET}" "$BASE/$DASHBOARD_ID")

# Find current bottom of dashboard for placement
NEXT_Y=$(echo "$EXISTING" | jq '[.result.tiles[] | (.y + .h)] | max')

UPDATED=$(echo "$EXISTING" | jq --argjson nextY "$NEXT_Y" '.result | {
  name, tags, filters,
  tiles: (.tiles + [{
    x: 0, y: $nextY, w: 12, h: 7,
    name: "New Trend",
    config: {
      displayType: "line",
      sourceId: "<source-id>",
      asRatio: false,
      alignDateRangeToGranularity: true,
      fillNulls: true,
      groupBy: "",
      select: [{aggFn: "count", valueExpression: "", alias: "Count",
                where: "ServiceName = '\''foo'\''", whereLanguage: "sql"}]
    }
  }])
}')

curl -s -u "${CLICKSTACK_API_KEY}:${CLICKSTACK_API_SECRET}" -X PUT "$BASE/$DASHBOARD_ID" \
  -H "Content-Type: application/json" -d "$UPDATED" \
  | jq '{id: .result.id, tileCount: (.result.tiles | length)}'
```

> **Always preserve existing `id` values when modifying tiles** — that's what keeps tiles stable across updates. New tiles without an `id` get one auto-assigned.

---

## Verification checklist

After every create/update, sanity-check the result:

```bash
curl -s -u "${CLICKSTACK_API_KEY}:${CLICKSTACK_API_SECRET}" "$BASE/$DASHBOARD_ID" | jq '{
  name: .result.name,
  tileCount: (.result.tiles | length),
  maxRight: ([.result.tiles[] | (.x + .w)] | max),
  bottom: ([.result.tiles[] | (.y + .h)] | max),
  blankMarkdowns: [.result.tiles[] | select(.config.displayType == "markdown") | select((.config.markdown // "") == "" and (.config.content // "") != "")] | length,
  emptyTiles: [.result.tiles[] | select(.config.select != null) | select(.config.select | length == 0)] | length
}'
```

Then **open the dashboard URL** and visually confirm:

- All markdown headers render (not blank)
- KPI numbers are formatted (commas, decimals)
- Charts have data (not "No results")
- Layout uses the full 24-column width

If a tile is empty: re-run the underlying SQL via `mcp-clickhouse` and check field name + case.

---

## Critical notes

- **Grid is 24 columns** — `x + w ≤ 24`. Old dashboards using 12 are legacy; build new ones at 24.
- **PUT replaces the full tile list** — omitting a tile deletes it; always GET first.
- **Tile IDs are stable across updates** — include existing `id` values to preserve tiles; new tiles get auto-assigned UUIDs.
- **Markdown body field is `markdown`**, not `content`. Old `content` payloads render blank.
- **Markdown headers use `h: 3`**, not `h: 1`.
- **Numbers need `numberFormat`**, charts need `h ≥ 6`.
- **Trace fields are PascalCase, log fields are lowercase.** `StatusCode='Error'` vs `SeverityText='error'`.
- **`whereLanguage` is required** on every select item (`"sql"` or `"lucene"`).
- **Filters apply per source** — duplicate them across `sourceId` values to cover logs + traces.
- **API is in Beta** but stable; endpoints under `/clickstack/` follow the same versioning as the rest of the ClickHouse Cloud API.
- **Credentials live in `~/.zshrc`** (`CLICKSTACK_API_KEY`, `CLICKSTACK_API_SECRET`, `CLICKSTACK_ORG_ID`, `CLICKSTACK_SERVICE_ID`) — re-source in every fresh shell.

---
name: project-setup
description: Onboard to the emitwise-v2 project by loading current context from the repo. Use when starting a new session on emitwise-v2, when the user asks to set up project context, or when you need a full picture of the codebase before starting work.
disable-model-invocation: true
---

# emitwise-v2 Project Setup

This skill loads current context for the [emitwise-v2](~/dev/emitwise-v2) codebase. Run this at the start of any emitwise-v2 session.

## Step 1: Read live project context

Read these files to get current state:

```
~/dev/emitwise-v2/AGENTS.md
```

Then list (don't read fully) to understand what's currently configured:

```
ls ~/dev/emitwise-v2/.cursor/rules/
ls ~/dev/emitwise-v2/.cursor/skills/
ls ~/dev/emitwise-v2/.cursor/agents/
```

## Step 2: Known stack (baked in)

No need to detect — the stack is known. Use this as authoritative context:

### Monorepo layout

| Area | Path | Notes |
|------|------|-------|
| React frontend | `front-end/apps/customer-app/` | Yarn 4 workspaces |
| Design system | `front-end/libs/design-system/` | Carbon Design System |
| Go services | `gateway/`, `accounts/`, `cap/`, `calculation-service/`, `classification-service/`, `collection-service/`, `decarb/`, `emission-factor-service/`, `export/`, `inventory-service/`, `notifications/`, `translation-service/`, `ai/` | Linked via `go.work` |
| Infrastructure | `infrastructure/` | Terraform (AWS/EKS) |
| Deployment | `deployment/` | Skaffold + Kubernetes |
| Python tooling | `shared-tools/`, `classification-service/product-classifier/` | Ruff + Pyright strict |
| Docs | `docs/` | Docusaurus 3 |

### Languages & runtimes

| Language | Version | Usage |
|----------|---------|-------|
| Go | 1.24 | All backend services |
| TypeScript | strict mode | Frontend (`customer-app`, `design-system`) |
| Python | 3.12 | `shared-tools`, product classifier ML |
| Node | 24.12 (`.nvmrc`) | Frontend tooling |

### Frontend stack

- **Framework**: React 18, Vite 7
- **State**: Redux Toolkit, React Query v3
- **UI**: Carbon Design System (`carbon-components-react`)
- **Testing**: Vitest (unit/integration), Playwright (E2E), MSW (API mocking)
- **Linting**: ESLint 8/9, Prettier 2.x, `@trivago/prettier-plugin-sort-imports`
- **Package manager**: Yarn 4 (`yarn@4.12.0`)

### Backend stack (Go services)

- **Framework**: Echo (`labstack/echo/v4`)
- **API**: OpenAPI specs + `oapi-codegen` code generation
- **Databases**: MongoDB (primary), PostgreSQL (pgx + goqu)
- **Auth**: Firebase
- **Observability**: OpenTelemetry (`@hyperdx/browser` on frontend)
- **Feature flags**: LaunchDarkly
- **Testing**: `go test` + testcontainers, gotestsum in CI
- **Linting**: golangci-lint v2 (`.golangci.yml`)

### CI/CD

- **System**: GitHub Actions (38 workflows in `.github/workflows/`)
- **Patterns**: Reusable partial workflows (`partial-go-test.yaml`, `partial-skaffold-build.yaml`, etc.)
- **Key workflows**: `gateway.yaml`, `frontend-customer-app.yaml`, `terraform.yaml`, `release.yaml`, `dev-deploy.yaml`

### TypeScript config

- `strict: true` across all TS packages
- `noEmit: true` in customer-app (Vite handles bundling)
- Path aliases: `@admin/*`, `@collect/*`, etc. in customer-app tsconfig

### Key commands (run from relevant subdirectory)

| Task | Command |
|------|---------|
| Frontend dev | `cd front-end && yarn dev` (in `apps/customer-app`) |
| Frontend test | `cd front-end && yarn test` |
| Frontend lint | `cd front-end && yarn lint` |
| Frontend typecheck | `cd front-end && yarn typecheck` |
| Frontend E2E | `cd front-end && yarn playwright` |
| Go test (service) | `cd <service> && go test ./...` |
| Go lint | `golangci-lint run` |
| Terraform plan | Via GitHub Actions or `terraform plan` in `infrastructure/<stack>/` |
| Skaffold dev | `skaffold dev` (K8s dev cluster) |

## Step 3: Understand personal vs team config

**Team-shared config** (in emitwise-v2 repo — do NOT modify without team discussion):
- `.cursor/rules/*.mdc` — project coding conventions
- `.cursor/skills/` — shared project skills
- `.cursor/agents/` — shared project agents

**Personal config** (from your dotfiles, available globally):
- `~/.cursor/skills/` — your personal skills (this one, `clickstack-dashboard`, `watch-pr-ci`, `tdd`, `testing`, `pr`, etc.)
- `~/.cursor/agents/` — your personal agents (`pr-reviewer`, `tdd-guardian`, `refactor-scan`, `progress-guardian`)
- `~/.cursor/hooks.json` — PostToolUse formatter hook for .ts/.tsx files

## Step 4: Output a session summary

Present a brief onboarding summary:

```
## emitwise-v2 Session Ready

**Repo**: ~/dev/emitwise-v2
**Stack**: Go 1.24 services | React 18 / Vite 7 frontend | Python 3.12 tooling
**Package manager**: Yarn 4 (frontend), go modules (backend)
**Testing**: Vitest + Playwright (frontend), go test + testcontainers (backend)
**CI**: GitHub Actions (38 workflows)

**AGENTS.md says**: [summary of key points from AGENTS.md]

**Team Cursor config**: [list of rules/skills/agents found in .cursor/]

**What are we working on today?**
```

#!/usr/bin/env python3
"""
Today's Cursor spend (chargeable usage) for your account via Admin API.

Requires Enterprise team + Admin API key from:
  cursor.com/dashboard → Settings → Advanced → Admin API Keys

Env:
  CURSOR_ADMIN_API_KEY or CURSOR_API_KEY — Basic auth (username=key, password empty)
  CURSOR_SPEND_EMAIL — Your Cursor login email (filters /teams/filtered-usage-events)

Optional:
  CURSOR_SPEND_CACHE_SECS — Cache TTL (default 900). Docs recommend not polling
    filtered-usage-events more than about once/hour for fresh aggregates.
  CURSOR_SPEND_INCLUDE_INCLUDED — If set, sum all chargedCents; default sums only
    rows where isChargeable is true (out-of-pocket style).
  CURSOR_SPEND_DEBUG — Print errors to stderr.

Personal Pro (no team API): not supported; script exits 0 with no output.
See https://cursor.com/docs/account/teams/admin-api
"""
from __future__ import annotations

import base64
import json
import os
import ssl
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path
from typing import Optional


API = "https://api.cursor.com/teams/filtered-usage-events"
DEFAULT_CACHE_SECS = 900
PAGE_SIZE = 100


def _cache_path() -> Path:
    base = os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache"))
    return Path(base) / "cursor-spend-today.json"


def _debug(msg: str) -> None:
    if os.environ.get("CURSOR_SPEND_DEBUG"):
        print(msg, file=sys.stderr)


def _today_range_ms() -> tuple[int, int]:
    now = datetime.now()
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    start_ms = int(start.timestamp() * 1000)
    end_ms = int(time.time() * 1000)
    return start_ms, end_ms


def _local_date_str() -> str:
    return datetime.now().strftime("%Y-%m-%d")


def _load_cache(cache_file: Path, ttl: int) -> Optional[str]:
    try:
        raw = cache_file.read_text()
        data = json.loads(raw)
    except (OSError, json.JSONDecodeError):
        return None
    if data.get("date") != _local_date_str():
        return None
    ts = data.get("ts", 0)
    if time.time() - ts > ttl:
        return None
    return data.get("display")


def _save_cache(cache_file: Path, display: str) -> None:
    try:
        cache_file.parent.mkdir(parents=True, exist_ok=True)
        cache_file.write_text(
            json.dumps(
                {
                    "date": _local_date_str(),
                    "ts": time.time(),
                    "display": display,
                },
                separators=(",", ":"),
            )
        )
    except OSError as e:
        _debug(f"cache write failed: {e}")


def _fetch_total(
    api_key: str,
    email: str,
    start_ms: int,
    end_ms: int,
    include_included: bool,
) -> Optional[float]:
    ctx = ssl.create_default_context()
    token = base64.b64encode(f"{api_key}:".encode()).decode().strip()

    total = 0.0
    page = 1
    while True:
        body = json.dumps(
            {
                "startDate": start_ms,
                "endDate": end_ms,
                "email": email,
                "page": page,
                "pageSize": PAGE_SIZE,
            }
        ).encode()
        req = urllib.request.Request(
            API,
            data=body,
            headers={
                "Authorization": f"Basic {token}",
                "Content-Type": "application/json",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, context=ctx, timeout=30) as resp:
                payload = json.load(resp)
        except urllib.error.HTTPError as e:
            err_body = e.read().decode(errors="replace")
            _debug(f"HTTP {e.code}: {err_body}")
            if e.code in (401, 403, 404):
                return None
            return None
        except urllib.error.URLError as e:
            _debug(f"request failed: {e}")
            return None

        for ev in payload.get("usageEvents") or []:
            if not include_included and not ev.get("isChargeable"):
                continue
            c = ev.get("chargedCents")
            if c is not None:
                total += float(c)

        pag = payload.get("pagination") or {}
        if not pag.get("hasNextPage"):
            break
        page += 1
        if page > 500:
            _debug("pagination cap reached")
            break

    return total


def main() -> int:
    key = os.environ.get("CURSOR_ADMIN_API_KEY") or os.environ.get("CURSOR_API_KEY")
    email = os.environ.get("CURSOR_SPEND_EMAIL", "").strip()
    if not key or not email:
        return 0

    try:
        ttl = int(os.environ.get("CURSOR_SPEND_CACHE_SECS", str(DEFAULT_CACHE_SECS)))
    except ValueError:
        ttl = DEFAULT_CACHE_SECS

    cache_file = _cache_path()
    cached = _load_cache(cache_file, ttl)
    if cached is not None:
        if cached:
            print(cached)
        return 0

    start_ms, end_ms = _today_range_ms()
    include_included = bool(os.environ.get("CURSOR_SPEND_INCLUDE_INCLUDED"))
    total = _fetch_total(key, email, start_ms, end_ms, include_included)
    if total is None:
        return 0

    # chargedCents are cents (may be fractional in API); display as dollars
    dollars = total / 100.0
    display = f"${dollars:,.2f}"
    _save_cache(cache_file, display)
    print(display)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

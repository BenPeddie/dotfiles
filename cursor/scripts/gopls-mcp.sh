#!/usr/bin/env bash
# Launches the gopls MCP (stdio) server with the Go toolchain that the
# emitwise-v2 workspace actually requires.
#
# Why this wrapper exists: the repo's go.work requires Go >= 1.26.3, but the
# goenv-shimmed `go` on PATH is 1.24.4 and gopls forces GOTOOLCHAIN=local for
# its `go list` subprocess (so it will not auto-switch). gopls therefore loads
# the workspace with whatever `go` is first on PATH, which must be 1.26.3.
#
# `go env GOROOT` resolves to the toolchain that GOTOOLCHAIN=auto selects for
# this workspace (currently the 1.26.3 toolchain), so this stays correct if
# go.work bumps its minimum version later.
set -euo pipefail

GOROOT="$(go env GOROOT)"
export PATH="${GOROOT}/bin:${PATH}"
exec /Users/bpeddie/go/1.24.4/bin/gopls mcp

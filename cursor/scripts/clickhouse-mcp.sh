#!/bin/bash
# Wrapper for ClickHouse MCP server.
# Cursor doesn't launch MCP servers via a login shell, so we must explicitly
# source the secrets file to get CLICKHOUSE_* env vars.
DOTFILES_DIR="$HOME/dev/dotfiles"
# shellcheck source=/dev/null
[[ -f "$DOTFILES_DIR/zsh/.zshrc.local" ]] && source "$DOTFILES_DIR/zsh/.zshrc.local"

exec uv run --with mcp-clickhouse --python 3.10 mcp-clickhouse

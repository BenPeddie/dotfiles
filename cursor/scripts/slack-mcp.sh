#!/bin/bash
# Wrapper for Slack MCP server.
# Cursor doesn't launch MCP servers via a login shell, so we must explicitly
# source the secrets file to get SLACK_* env vars.
DOTFILES_DIR="$HOME/dev/dotfiles"
# shellcheck source=/dev/null
[[ -f "$DOTFILES_DIR/zsh/.zshrc.local" ]] && source "$DOTFILES_DIR/zsh/.zshrc.local"

exec npx -y @modelcontextprotocol/server-slack

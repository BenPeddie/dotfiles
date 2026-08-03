#!/bin/bash
# Wrapper for GitHub MCP server.
# Reads $GITHUB_PERSONAL_ACCESS_TOKEN from env (set in ~/.zshrc.local) and
# passes it to the Docker container, keeping the secret out of mcp.json.
exec docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" ghcr.io/github/github-mcp-server

#!/bin/bash
# Wrapper for LaunchDarkly MCP server.
# Reads $LAUNCHDARKLY_MCP_API_KEY from env (set in ~/.zshrc.local) and
# passes it as the --api-key argument, keeping the secret out of mcp.json.
exec npx -y --package @launchdarkly/mcp-server -- mcp start --api-key "$LAUNCHDARKLY_MCP_API_KEY"

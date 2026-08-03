# Dotfiles

Personal dotfiles for macOS development environment.

## Quick Setup (New Machine)

```bash
curl -fsSL https://raw.githubusercontent.com/BenPeddie/dotfiles/main/setup.sh | bash
```

Or manually:

```bash
git clone https://github.com/BenPeddie/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles && ./setup.sh
```

This installs everything: Homebrew, Oh My Zsh, Powerlevel10k, fonts, CLI tools, and symlinks your configs.

## Structure

```
dotfiles/
├── zsh/
│   ├── zshrc          # Main zsh config (Oh My Zsh, aliases, etc.)
│   ├── zprofile       # Login shell config (Homebrew, goenv)
│   └── p10k.zsh       # Powerlevel10k theme configuration
├── starship/
│   └── starship.toml  # Starship prompt configuration (alternative)
├── git/
│   └── gitconfig      # Git configuration
├── cursor/            # Cursor IDE personal config (symlinked into ~/.cursor/)
│   ├── mcp.json       # MCP server config (secrets via env vars)
│   ├── skills/        # Personal agent skills
│   ├── agents/        # Personal agents
│   ├── hooks.json     # Hook config (PostToolUse formatter)
│   ├── hooks/         # Hook scripts
│   └── scripts/       # MCP helper scripts
├── scripts/
│   ├── aws-sso-expiry.sh      # AWS SSO expiry checker (standalone)
│   └── cursor-spend-today.py  # Cursor spend today (Enterprise Admin API)
├── install.sh         # Installation script
└── README.md
```

## Installation

```bash
cd ~/dev/dotfiles
./install.sh
```

This will create symlinks from your home directory to the dotfiles repo.

## Features

- **Oh My Zsh** with plugins: git, zsh-autosuggestions, zsh-syntax-highlighting, history-substring-search, brew, macos
- **Powerlevel10k** prompt with AWS SSO expiry indicator and optional Cursor spend-today (default)
- **Starship** prompt available as alternative
- **goenv** for Go version management
- **NVM** for Node version management
- Custom aliases for git, AWS SSO, Skaffold

## Prompt Options

### Powerlevel10k (default)

Feature-rich prompt with the AWS SSO expiry segment. To customize:

```bash
p10k configure
```

### Starship (alternative)

Simpler, cross-shell prompt. To switch:

1. Edit `~/.zshrc`
2. Change `USE_POWERLEVEL10K=true` to `USE_POWERLEVEL10K=false`
3. Reload: `source ~/.zshrc`

## AWS SSO Expiry Indicator

Shows your AWS session time remaining directly in your terminal prompt:

| Colour | Meaning |
|--------|---------|
| 🟢 Green | > 1 hour remaining |
| 🟡 Yellow | 30–60 minutes |
| 🟠 Orange | < 30 minutes |
| 🔴 Red | Expired |

The indicator disappears entirely when no AWS credentials exist.

## Cursor spend today

Shows **chargeable** Cursor usage for the current local calendar day on the right side of the prompt (sums `chargedCents` on usage events where `isChargeable` is true). Requires an [Enterprise Admin API](https://cursor.com/docs/account/teams/admin-api) key and your Cursor login email in `zsh/.zshrc.local`:

- `CURSOR_ADMIN_API_KEY` — from the dashboard (Settings → Advanced)
- `CURSOR_SPEND_EMAIL` — your account email (API filter)

Results are cached under `~/.cache/cursor-spend-today.json` (default TTL 15 minutes; override with `CURSOR_SPEND_CACHE_SECS`). **Individual Pro plans** do not expose this API; use [cursor.com/dashboard](https://cursor.com/dashboard) for usage instead.

### How it works

1. Checks `~/.aws/cli/cache/*.json` for role session credentials (`Expiration` field)
2. Falls back to SSO access token in `~/.aws/sso/cache/*.json` (`expiresAt` field)
3. Picks the credential with the latest expiry when multiple exist
4. Renders a color-coded segment in your prompt

## Cursor Personal Config

Personal Cursor IDE config lives in `cursor/` and is symlinked into `~/.cursor/` by `install.sh`. This keeps your AI tooling version-controlled alongside your other dotfiles.

### What's managed

| Type | Path in dotfiles | Symlinked to |
|------|-----------------|--------------|
| MCP servers | `cursor/mcp.json` | `~/.cursor/mcp.json` |
| Skills | `cursor/skills/<name>/` | `~/.cursor/skills/<name>/` |
| Agents | `cursor/agents/<name>.md` | `~/.cursor/agents/<name>.md` |
| Hooks config | `cursor/hooks.json` | `~/.cursor/hooks.json` |
| Hook scripts | `cursor/hooks/<name>` | `~/.cursor/hooks/<name>` |

### Skills included

| Skill | Invoke | Description |
|-------|--------|-------------|
| `project-setup` | `/project-setup` | Load emitwise-v2 project context at session start |
| `pr` | `/pr` | Create a PR following team standards |
| `plan` | `/plan` | Write a plan document before implementing |
| `continue` | `/continue` | Resume work after a PR is merged |
| `tdd` | auto | TDD red-green-refactor workflow |
| `testing` | auto | Testing patterns and best practices |
| `react-testing` | auto | React + Vitest + Testing Library patterns |
| `front-end-testing` | auto | Frontend testing strategy |
| `typescript-strict` | auto | TypeScript strict mode patterns |
| `planning` | auto | Planning in small increments |
| `refactoring` | auto | Refactoring assessment methodology |
| `expectations` | auto | Documentation and expectations |
| `ci-debugging` | auto | Diagnosing CI failures |
| `functional` | auto | Functional programming patterns |
| `mutation-testing` | auto | Mutation testing for test quality |
| `clickstack-dashboard` | auto | Manage ClickStack/HyperDX dashboards |
| `watch-pr-ci` | auto | Monitor PR CI checks and auto-fix failures |

### Agents included

| Agent | Description |
|-------|-------------|
| `pr-reviewer` | Systematic PR review against quality standards |
| `tdd-guardian` | TDD compliance coach and enforcer |
| `refactor-scan` | Code quality and refactoring opportunities |
| `progress-guardian` | Track progress through plan files |

### MCP servers and secrets

All secrets are referenced as `$ENV_VAR` in `cursor/mcp.json` -- never hardcoded. They are populated from `zsh/.zshrc.local` (gitignored). Required env vars (see `zsh/.zshrc.local.template`):

- `GITHUB_PERSONAL_ACCESS_TOKEN` -- GitHub MCP
- `LAUNCHDARKLY_MCP_API_KEY` -- LaunchDarkly MCP (see `cursor/scripts/launchdarkly-mcp.sh`)
- `CLICKHOUSE_HOST`, `CLICKHOUSE_USER`, `CLICKHOUSE_PASSWORD`, etc. -- ClickHouse MCP
- `SLACK_BOT_TOKEN`, `SLACK_TEAM_ID` -- Slack MCP (see `cursor/scripts/slack-mcp.sh`)

### Adding a new skill

```bash
mkdir -p cursor/skills/my-skill
# Write cursor/skills/my-skill/SKILL.md with YAML frontmatter (name + description)
./install.sh  # re-run to symlink the new skill
```

### Project-level Cursor config

Project-level rules/skills/agents in `emitwise-v2/.cursor/` are **team-shared** and managed in that repo. Do not put personal-only config there.

## Reverting Changes

To revert to Starship:
```bash
# Edit zshrc
USE_POWERLEVEL10K=false
source ~/.zshrc
```

To fully restore original files:
```bash
cp ~/.dotfiles_backup/<timestamp>/.zshrc ~/
# etc.
```

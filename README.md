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

## Reverting Changes

Original config files are backed up to `~/.dotfiles_backup/<timestamp>/` during installation.

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

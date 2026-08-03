#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Create backup directory
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

backup_and_link() {
    local src="$1"
    local dest="$2"
    
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up existing $dest to $BACKUP_DIR/"
        mv "$dest" "$BACKUP_DIR/"
    elif [ -L "$dest" ]; then
        rm "$dest"
    fi
    
    echo "Linking $src -> $dest"
    ln -s "$src" "$dest"
}

# Zsh configs
backup_and_link "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/zsh/zprofile" "$HOME/.zprofile"
backup_and_link "$DOTFILES_DIR/zsh/p10k.zsh" "$HOME/.p10k.zsh"

# Starship config
mkdir -p "$HOME/.config"
backup_and_link "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# Git config
backup_and_link "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

# Create local secrets file from template if it doesn't exist
if [[ ! -f "$DOTFILES_DIR/zsh/.zshrc.local" ]] && [[ -f "$DOTFILES_DIR/zsh/.zshrc.local.template" ]]; then
    echo "Creating zsh/.zshrc.local from template (fill in your secrets)"
    cp "$DOTFILES_DIR/zsh/.zshrc.local.template" "$DOTFILES_DIR/zsh/.zshrc.local"
fi

# Make scripts executable
chmod +x "$DOTFILES_DIR/scripts/"*.sh 2>/dev/null || true

# ── Cursor personal config ────────────────────────────────────────────────────

# MCP config (secrets come from env vars set in zsh/.zshrc.local)
mkdir -p "$HOME/.cursor"
backup_and_link "$DOTFILES_DIR/cursor/mcp.json" "$HOME/.cursor/mcp.json"

# Skills (each skill directory linked individually to avoid disrupting
# Cursor's own managed skills in ~/.cursor/skills-cursor/)
mkdir -p "$HOME/.cursor/skills"
for skill_dir in "$DOTFILES_DIR/cursor/skills/"*/; do
    skill_name=$(basename "$skill_dir")
    backup_and_link "$skill_dir" "$HOME/.cursor/skills/$skill_name"
done

# Commands (slash-invoked workflows, equivalent to Claude Code's ~/.claude/commands/)
if [ -d "$DOTFILES_DIR/cursor/commands" ]; then
    mkdir -p "$HOME/.cursor/commands"
    for cmd_file in "$DOTFILES_DIR/cursor/commands/"*.md; do
        [ -f "$cmd_file" ] || continue
        cmd_name=$(basename "$cmd_file")
        backup_and_link "$cmd_file" "$HOME/.cursor/commands/$cmd_name"
    done
fi

# Agents
if [ -d "$DOTFILES_DIR/cursor/agents" ]; then
    mkdir -p "$HOME/.cursor/agents"
    for agent_file in "$DOTFILES_DIR/cursor/agents/"*.md; do
        [ -f "$agent_file" ] || continue
        agent_name=$(basename "$agent_file")
        backup_and_link "$agent_file" "$HOME/.cursor/agents/$agent_name"
    done
fi

# Hooks config
if [ -f "$DOTFILES_DIR/cursor/hooks.json" ]; then
    backup_and_link "$DOTFILES_DIR/cursor/hooks.json" "$HOME/.cursor/hooks.json"
fi

# Hook scripts
if [ -d "$DOTFILES_DIR/cursor/hooks" ]; then
    mkdir -p "$HOME/.cursor/hooks"
    for hook_script in "$DOTFILES_DIR/cursor/hooks/"*; do
        [ -f "$hook_script" ] || continue
        hook_name=$(basename "$hook_script")
        backup_and_link "$hook_script" "$HOME/.cursor/hooks/$hook_name"
    done
fi

# MCP helper scripts (must be executable for Cursor to invoke them)
chmod +x "$DOTFILES_DIR/cursor/scripts/"* 2>/dev/null || true

echo ""
echo "✓ Dotfiles installed successfully!"
echo "  Backups saved to: $BACKUP_DIR"
echo ""
echo "Reload your shell: source ~/.zshrc"
echo ""
echo "Cursor personal config symlinked:"
echo "  ~/.cursor/mcp.json"
echo "  ~/.cursor/commands/ ($(ls "$DOTFILES_DIR/cursor/commands/"*.md 2>/dev/null | wc -l | tr -d ' ') commands)"
echo "  ~/.cursor/skills/ ($(ls "$DOTFILES_DIR/cursor/skills" | wc -l | tr -d ' ') skills)"
echo "  ~/.cursor/agents/ ($(ls "$DOTFILES_DIR/cursor/agents/"*.md 2>/dev/null | wc -l | tr -d ' ') agents)"
echo "  ~/.cursor/hooks.json"
echo ""
echo "⚠️  Populate cursor env vars in zsh/.zshrc.local (see .zshrc.local.template)"

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

echo ""
echo "✓ Dotfiles installed successfully!"
echo "  Backups saved to: $BACKUP_DIR"
echo ""
echo "Reload your shell: source ~/.zshrc"

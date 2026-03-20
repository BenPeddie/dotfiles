#!/bin/bash
#
# Dotfiles Setup Script
# Run this on a fresh macOS machine to set up your dev environment
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/BenPeddie/dotfiles/main/setup.sh | bash
#
# Or clone and run:
#   git clone https://github.com/BenPeddie/dotfiles.git ~/dev/dotfiles
#   cd ~/dev/dotfiles && ./setup.sh
#

set -e

DOTFILES_DIR="$HOME/dev/dotfiles"
REPO_URL="https://github.com/BenPeddie/dotfiles.git"

echo "=========================================="
echo "  Dotfiles Setup"
echo "=========================================="
echo ""

# Check for macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is designed for macOS"
    exit 1
fi

# Install Xcode Command Line Tools if needed
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Please complete the Xcode installation and re-run this script."
    exit 0
fi

# Install Homebrew if needed
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "Installing packages via Homebrew..."
brew install \
    git \
    gh \
    powerlevel10k \
    starship \
    fzf \
    eza \
    bat \
    ripgrep \
    fd \
    delta \
    lazygit \
    nvm \
    goenv \
    awscli

# Install Nerd Font
echo "Installing MesloLG Nerd Font..."
brew install --cask font-meslo-lg-nerd-font

# Install Oh My Zsh if needed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/history-substring-search" ]]; then
    echo "Installing history-substring-search..."
    git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/history-substring-search"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-abbr" ]]; then
    echo "Installing zsh-abbr..."
    git clone https://github.com/olets/zsh-abbr "$ZSH_CUSTOM/plugins/zsh-abbr"
    cd "$ZSH_CUSTOM/plugins/zsh-abbr" && git submodule update --init --recursive
    cd -
fi

# Clone dotfiles if not already present
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Cloning dotfiles..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# Run the install script to create symlinks
echo "Creating symlinks..."
cd "$DOTFILES_DIR"
./install.sh

# Set up fzf key bindings
if [[ -f "/opt/homebrew/opt/fzf/install" ]]; then
    echo "Setting up fzf..."
    /opt/homebrew/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

# Create NVM directory
mkdir -p "$HOME/.nvm"

# Create dev directory
mkdir -p "$HOME/dev"

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (or run: exec zsh)"
echo "  2. Set your terminal font to 'MesloLGS NF' or 'MesloLGM Nerd Font'"
echo "  3. Fill in your secrets: \$EDITOR $DOTFILES_DIR/zsh/.zshrc.local"
echo "  4. Log in to GitHub: gh auth login"
echo "  5. Log in to AWS: aws configure sso"
echo ""
echo "Your dotfiles are in: $DOTFILES_DIR"
echo ""

#!/usr/bin/env bash
set -euo pipefail

# DIR is the directory of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=common.sh
source "$DIR/common.sh"

# Homebrew first: its installer also installs the Xcode Command Line Tools,
# which provide the git that Oh My Zsh's installer needs.
read -r -p "Press ENTER to install Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# A fresh install is not on this script's PATH yet: load it (Apple Silicon, then Intel).
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [ -x "$brew_bin" ]; then
    eval "$("$brew_bin" shellenv)"
    break
  fi
done
log "Homebrew ready"

# git, tmux, python3
read -r -p "Press ENTER to install CLI tooling"
brew install git tmux python3 thefuck direnv
link_git_and_tmux

read -r -p "Press ENTER to install Oh My Zsh"
install_oh_my_zsh

# Neovim environment + Nerd Font
read -r -p "Press ENTER to install the Neovim environment"
brew install neovim node ruby fd ripgrep fzf unzip zip wget
brew install --cask font-jetbrains-mono-nerd-font
link_neovim_config

# Default shell (zsh is already the default on macOS 10.15+)
read -r -p "Press ENTER to set zsh as the default shell"
set_default_shell
exec zsh

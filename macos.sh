#!/usr/bin/env bash
set -euo pipefail

# DIR is the directory of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

log() { printf '\n==> %s\n\n' "$1"; }

# Symlink $2 -> $1, backing up anything already at the target.
# Safe to re-run: a target that already points at $1 is left alone.
backup_and_link() {
  local src="$1" dst="$2"
  if [ "$(readlink "$dst" 2>/dev/null)" = "$src" ]; then
    return
  fi
  if [ -L "$dst" ] || [ -e "$dst" ]; then
    mv "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
  fi
  ln -s "$src" "$dst"
}

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
backup_and_link "$DIR/git/gitconfig" "$HOME/.gitconfig"
backup_and_link "$DIR/git/git_commit_template.txt" "$HOME/.git_commit_template"
backup_and_link "$DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
# Git identity is per-machine: seed it from the tracked example, never symlink it.
mkdir -p "$HOME/.config/git"
if [ ! -f "$HOME/.config/git/config.local" ]; then
  cp "$DIR/git/config.local.example" "$HOME/.config/git/config.local"
  log "Created ~/.config/git/config.local — set your name and email there before committing."
fi
log "git, tmux and Python configured"

read -r -p "Press ENTER to install Oh My Zsh"
backup_and_link "$DIR/zsh/zshenv" "$HOME/.zshenv"
backup_and_link "$DIR/zsh/zshprofile" "$HOME/.zprofile"
backup_and_link "$DIR/zsh/zshrc" "$HOME/.zshrc"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  # KEEP_ZSHRC: leave the symlinked ~/.zshrc alone. GIT_CONFIG_GLOBAL=/dev/null: clone
  # over HTTPS, since gitconfig rewrites github.com to SSH and keys may not be set up yet.
  KEEP_ZSHRC=yes GIT_CONFIG_GLOBAL=/dev/null \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
log "Oh My Zsh installed and zsh configured"

# Neovim environment + Nerd Font
read -r -p "Press ENTER to install the Neovim environment"
brew install neovim node ruby fd ripgrep fzf unzip zip wget
brew install --cask font-jetbrains-mono-nerd-font
mkdir -p "$HOME/.config"
# Use the dotfiles-tracked config as the single source of truth.
backup_and_link "$DIR/nvim" "$HOME/.config/nvim"
# Install/sync plugins headlessly so the first real launch is ready to go
# (over HTTPS, for the same reason as Oh My Zsh above).
GIT_CONFIG_GLOBAL=/dev/null nvim --headless "+Lazy! sync" +qa || true
log "Neovim installed and config symlinked. Set 'JetBrainsMono Nerd Font' as your terminal font."

# Default shell (zsh is already the default on macOS 10.15+)
read -r -p "Press ENTER to set zsh as the default shell"
if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)" || true
fi
exec zsh

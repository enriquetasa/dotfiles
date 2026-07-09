#!/usr/bin/env bash
set -euo pipefail

# DIR is the directory of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

log() { printf '\n==> %s\n\n' "$1"; }

# Pause between stages when run interactively; just log when piped/headless.
pause() {
  if [ -t 0 ]; then
    read -r -p "Press ENTER to $1"
  else
    log "$1"
  fi
}

# Symlink $2 -> $1, backing up anything already at the target.
# No-op when the symlink is already correct, so re-runs stay clean.
backup_and_link() {
  local src="$1" dst="$2"
  if [ "$(readlink "$dst" 2>/dev/null || true)" = "$src" ]; then
    return 0
  fi
  if [ -L "$dst" ] || [ -e "$dst" ]; then
    mv "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
  fi
  ln -s "$src" "$dst"
}

# Oh My Zsh custom plugins; zshrc enables them when the directories exist.
install_omz_plugins() {
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  local repo
  for repo in zsh-autosuggestions zsh-syntax-highlighting; do
    if [ ! -d "$custom/plugins/$repo" ]; then
      # Plain https clone even if gitconfig rewrites github to SSH —
      # fresh machines have no SSH keys yet.
      GIT_CONFIG_GLOBAL=/dev/null git clone --depth=1 \
        "https://github.com/zsh-users/$repo" "$custom/plugins/$repo"
    fi
  done
}

pause "install Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
install_omz_plugins
backup_and_link "$DIR/zsh/zshenv" "$HOME/.zshenv"
backup_and_link "$DIR/zsh/zshprofile" "$HOME/.zprofile"
backup_and_link "$DIR/zsh/zshrc" "$HOME/.zshrc"
log "Oh My Zsh installed and zsh configured"

# Homebrew
pause "install Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # A fresh install is not on this script's PATH yet — the brew calls
  # below would fail on a brand-new machine without this.
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi
log "Homebrew ready"

# All packages come from the Brewfile — one declarative, diffable list.
pause "install packages from the Brewfile"
brew bundle --file="$DIR/Brewfile"
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

# Neovim config (packages and the Nerd Font came from the Brewfile)
pause "set up Neovim"
mkdir -p "$HOME/.config"
# Use the dotfiles-tracked config as the single source of truth.
backup_and_link "$DIR/nvim" "$HOME/.config/nvim"
# Install/sync plugins headlessly so the first real launch is ready to go.
nvim --headless "+Lazy! sync" +qa || true
log "Neovim installed and config symlinked. Set 'JetBrainsMono Nerd Font' as your terminal font."

# Default shell
pause "set zsh as the default shell"
zsh_path="$(command -v zsh)"
# chsh refuses shells not registered in /etc/shells (e.g. Homebrew zsh)
if ! grep -qx "$zsh_path" /etc/shells; then
  zsh_path="/bin/zsh"
fi
if [ "${SHELL:-}" != "$zsh_path" ]; then
  chsh -s "$zsh_path" || log "chsh failed — change your default shell manually."
fi
if [ -t 0 ]; then
  exec zsh -l
fi

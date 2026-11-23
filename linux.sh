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

# Neovim from the official release build: LazyVim needs 0.11.2+, and Debian/Ubuntu
# LTS packages are older than that.
install_neovim() {
  local arch
  case "$(uname -m)" in
    x86_64) arch="x86_64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *)
      log "No Neovim release build for $(uname -m); install Neovim 0.11.2+ yourself."
      return
      ;;
  esac
  local tmp
  tmp="$(mktemp -d)"
  wget -qO "$tmp/nvim.tar.gz" \
    "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz"
  sudo rm -rf "/opt/nvim-linux-${arch}"
  sudo tar -C /opt -xzf "$tmp/nvim.tar.gz"
  sudo ln -sfn "/opt/nvim-linux-${arch}/bin/nvim" /usr/local/bin/nvim
  rm -rf "$tmp"
}

# Install JetBrainsMono Nerd Font into the user font dir.
install_nerd_font() {
  local font_dir="$HOME/.local/share/fonts"
  mkdir -p "$font_dir"
  local tmp
  tmp="$(mktemp -d)"
  wget -qO "$tmp/JetBrainsMono.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -o "$tmp/JetBrainsMono.zip" -d "$font_dir" >/dev/null
  rm -rf "$tmp"
  fc-cache -f >/dev/null
}

# CLI tooling first: Oh My Zsh's installer needs zsh, git and curl to exist.
read -r -p "Press ENTER to install CLI tooling"
sudo apt update
sudo apt upgrade -y
# npm and ruby-full let Mason install the LSPs and formatters the Neovim config uses.
sudo apt install -y git tmux python3 direnv python3-pip python3-venv \
  zsh nodejs npm ruby-full golang postgresql nginx curl build-essential \
  ripgrep wget ca-certificates gnupg lsb-release make cmake fd-find \
  fzf unzip zip fontconfig
# thefuck is not packaged on newer Debian/Ubuntu; try apt, then pip, without failing setup.
sudo apt install -y thefuck 2>/dev/null \
  || pip3 install --user thefuck 2>/dev/null \
  || pip3 install --user --break-system-packages thefuck 2>/dev/null \
  || log "Skipped thefuck (install it manually if you want it)."
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
install_neovim
install_nerd_font
mkdir -p "$HOME/.config"
# Use the dotfiles-tracked config as the single source of truth.
backup_and_link "$DIR/nvim" "$HOME/.config/nvim"
# Install/sync plugins headlessly so the first real launch is ready to go
# (over HTTPS, for the same reason as Oh My Zsh above).
GIT_CONFIG_GLOBAL=/dev/null nvim --headless "+Lazy! sync" +qa || true
log "Neovim installed and config symlinked. Set 'JetBrainsMono Nerd Font' as your terminal font."

# Cleanup
read -r -p "Press ENTER to clean up apt"
sudo apt autoremove -y
sudo apt autoclean

# Default shell
read -r -p "Press ENTER to set zsh as the default shell"
if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)" || true
fi
exec zsh

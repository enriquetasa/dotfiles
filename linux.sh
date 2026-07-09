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

# LazyVim needs Neovim >= 0.9; Debian/Ubuntu apt often ships older.
# Keep the apt version when it is new enough, otherwise install the
# latest release tarball to /opt/nvim (symlinked into /usr/local/bin,
# which shadows /usr/bin/nvim on PATH).
ensure_neovim() {
  local v=""
  if command -v nvim >/dev/null 2>&1; then
    v="$(nvim --version | head -1 | sed -E 's/^NVIM v?([0-9]+\.[0-9]+).*/\1/')"
    case "$v" in
      0.[0-8]) log "Neovim $v is too old for LazyVim; installing the latest release." ;;
      *) return 0 ;;
    esac
  fi
  local tarball
  case "$(uname -m)" in
    x86_64) tarball="nvim-linux-x86_64.tar.gz" ;;
    aarch64) tarball="nvim-linux-arm64.tar.gz" ;;
    *) log "No prebuilt Neovim for $(uname -m) — install Neovim >= 0.9 manually."; return 0 ;;
  esac
  local tmp
  tmp="$(mktemp -d)"
  wget -qO "$tmp/nvim.tar.gz" \
    "https://github.com/neovim/neovim/releases/latest/download/$tarball"
  sudo rm -rf /opt/nvim
  sudo mkdir -p /opt/nvim
  sudo tar -xzf "$tmp/nvim.tar.gz" -C /opt/nvim --strip-components=1
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  rm -rf "$tmp"
}

pause "install Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
backup_and_link "$DIR/zsh/zshenv" "$HOME/.zshenv"
backup_and_link "$DIR/zsh/zshprofile" "$HOME/.zprofile"
backup_and_link "$DIR/zsh/zshrc" "$HOME/.zshrc"
log "Oh My Zsh installed and zsh configured"

# CLI tooling
pause "install CLI tooling"
sudo apt update
sudo apt upgrade -y
sudo apt install -y git tmux python3 direnv python3-pip python3-venv \
  zsh nodejs golang postgresql nginx curl build-essential \
  ripgrep wget ca-certificates gnupg lsb-release make cmake fd-find \
  fzf unzip zip fontconfig
# thefuck is not packaged on newer Debian/Ubuntu; try apt, then pip, without failing setup.
sudo apt install -y thefuck 2>/dev/null \
  || pip3 install --user thefuck 2>/dev/null \
  || pip3 install --user --break-system-packages thefuck 2>/dev/null \
  || log "Skipped thefuck (install it manually if you want it)."
# Debian installs fd as 'fdfind'; provide the 'fd' name LazyVim/telescope expect.
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi
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

# Neovim environment + Nerd Font
pause "install the Neovim environment"
sudo apt install -y neovim || true
ensure_neovim
install_nerd_font
mkdir -p "$HOME/.config"
# Use the dotfiles-tracked config as the single source of truth.
backup_and_link "$DIR/nvim" "$HOME/.config/nvim"
# Install/sync plugins headlessly so the first real launch is ready to go.
nvim --headless "+Lazy! sync" +qa || true
log "Neovim installed and config symlinked. Set 'JetBrainsMono Nerd Font' as your terminal font."

# Cleanup
pause "clean up apt"
sudo apt autoremove -y
sudo apt autoclean

# Default shell
pause "set zsh as the default shell"
zsh_path="$(command -v zsh)"
# chsh refuses shells not registered in /etc/shells
if ! grep -qx "$zsh_path" /etc/shells; then
  echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
fi
if [ "${SHELL:-}" != "$zsh_path" ]; then
  chsh -s "$zsh_path" || log "chsh failed — change your default shell manually."
fi
if [ -t 0 ]; then
  exec zsh -l
fi

#!/usr/bin/env bash
set -euo pipefail

# DIR is the directory of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=common.sh
source "$DIR/common.sh"

# zsh/zshenv sets LC_ALL=en_US.UTF-8, which warns on every shell if the locale is missing.
ensure_locale() {
  if locale -a 2>/dev/null | grep -qiE '^en_US\.utf-?8$'; then
    return
  fi
  # Debian generates what /etc/locale.gen lists; Ubuntu also takes the name as an argument.
  if [ -f /etc/locale.gen ]; then
    sudo sed -i 's/^# *\(en_US\.UTF-8 UTF-8\)/\1/' /etc/locale.gen
  fi
  sudo locale-gen en_US.UTF-8
}

# thefuck: apt where packaged, else pip. Keep it only if it runs: Ubuntu 24.04's
# package crashes on Python 3.12, and zshrc loads the plugin whenever thefuck exists.
install_thefuck() {
  sudo apt install -y thefuck 2>/dev/null \
    || pip3 install --user thefuck 2>/dev/null \
    || pip3 install --user --break-system-packages thefuck 2>/dev/null \
    || true
  if PATH="$HOME/.local/bin:$PATH" thefuck --version >/dev/null 2>&1; then
    return
  fi
  sudo apt remove -y thefuck >/dev/null 2>&1 || true
  pip3 uninstall -y thefuck >/dev/null 2>&1 \
    || pip3 uninstall -y --break-system-packages thefuck >/dev/null 2>&1 \
    || true
  log "Skipped thefuck: no build that runs here (install it manually if you want it)."
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

# Janitor: hourly age-based cleanup of temp files, weekly report, disk warnings.
# Linger keeps the user timers running when nobody is logged in.
install_janitor() {
  mkdir -p "$HOME/.local/bin" "$HOME/.config/systemd/user"
  backup_and_link "$DIR/janitor/janitor.sh" "$HOME/.local/bin/janitor"
  local unit
  for unit in "$DIR"/janitor/systemd/*; do
    backup_and_link "$unit" "$HOME/.config/systemd/user/$(basename "$unit")"
  done
  loginctl enable-linger "$USER" \
    || log "Could not enable linger: the janitor only runs while you are logged in."
  systemctl --user daemon-reload
  systemctl --user enable --now janitor.timer janitor-report.timer
  log "Janitor installed. Preview a run with: janitor clean --dry-run"
}

# CLI tooling first: Oh My Zsh's installer needs zsh, git and curl to exist.
read -r -p "Press ENTER to install CLI tooling"
sudo apt update
sudo apt upgrade -y
# npm and ruby-full let Mason install the LSPs and formatters the Neovim config uses.
sudo apt install -y git tmux python3 direnv python3-pip python3-venv \
  zsh nodejs npm ruby-full golang postgresql nginx curl build-essential \
  ripgrep wget ca-certificates gnupg lsb-release make cmake fd-find \
  fzf unzip zip fontconfig locales
install_thefuck
ensure_locale
link_git_and_tmux

read -r -p "Press ENTER to install Oh My Zsh"
install_oh_my_zsh

# Neovim environment + Nerd Font
read -r -p "Press ENTER to install the Neovim environment"
install_neovim
install_nerd_font
link_neovim_config

read -r -p "Press ENTER to install the janitor timers"
install_janitor

# Cleanup
read -r -p "Press ENTER to clean up apt"
sudo apt autoremove -y
sudo apt autoclean

# Default shell
read -r -p "Press ENTER to set zsh as the default shell"
set_default_shell
exec zsh

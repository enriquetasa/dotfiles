#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Pinned Nerd Fonts release (JetBrainsMono.zip); bump when upgrading
NERD_FONTS_JETBRAINS_TAG="v3.3.0"

# Set DOTFILES_FULL_UPGRADE=1 to run distro / Homebrew full upgrades (can be slow and risky on a working machine).
maybe_distro_upgrade() {
  if [[ -n "${DOTFILES_FULL_UPGRADE:-}" ]]; then
    return 0
  fi
  echo "Skipping full system upgrade (set DOTFILES_FULL_UPGRADE=1 to run apt/dnf/pacman/brew upgrade-all)."
  return 1
}

pause_until_enter() {
  [[ -n "${DOTFILES_NONINTERACTIVE:-}" ]] && return 0
  read -r -p "Press Enter to continue..."
}

require_commands() {
  local missing=()
  local c
  for c in "$@"; do
    command -v "${c}" >/dev/null 2>&1 || missing+=("${c}")
  done
  if [[ "${#missing[@]}" -gt 0 ]]; then
    echo "Missing required commands: ${missing[*]}"
    echo "Install them, then re-run setup.sh"
    exit 1
  fi
}

ensure_oh_my_zsh() {
  if [[ -f "${HOME}/.oh-my-zsh/oh-my-zsh.sh" ]]; then
    return 0
  fi
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

ensure_brew_in_path() {
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv 2>/dev/null || true)"
    return 0
  fi
  local brew_prefix=""
  for brew_prefix in /opt/homebrew /usr/local; do
    if [[ -x "${brew_prefix}/bin/brew" ]]; then
      eval "$("${brew_prefix}/bin/brew" shellenv)"
      return 0
    fi
  done
  return 1
}

ensure_thefuck() {
  command -v thefuck >/dev/null 2>&1 && return 0
  command -v pip3 >/dev/null 2>&1 || return 0
  pip3 install --user thefuck 2>/dev/null && return 0
  pip3 install --user --break-system-packages thefuck 2>/dev/null || true
}

ensure_nvim_python_tools() {
  command -v pip3 >/dev/null 2>&1 || return 0
  # Used by jedi/black/isort and :python3 in Neovim (Black major aligned with psf/black vim plugin)
  pip3 install --user pynvim 'black>=24' 'isort>=5' 2>/dev/null && return 0
  pip3 install --user --break-system-packages pynvim 'black>=24' 'isort>=5' 2>/dev/null || true
}

ensure_git_identity_file() {
  mkdir -p "${HOME}/.config/git"
  local dest="${HOME}/.config/git/config.local"
  [[ -f "${dest}" ]] && return 0
  if [[ -n "${GIT_AUTHOR_NAME:-}" && -n "${GIT_AUTHOR_EMAIL:-}" ]]; then
    printf '[user]\n\tname = %s\n\temail = %s\n' "${GIT_AUTHOR_NAME}" "${GIT_AUTHOR_EMAIL}" >"${dest}"
    echo "Wrote Git identity from GIT_AUTHOR_NAME / GIT_AUTHOR_EMAIL to ${dest}"
    return 0
  fi
  cp "${DOTFILES_ROOT}/git/config.local.example" "${dest}"
  echo "Created ${dest} from template — set your name and email before your first commit."
}

ensure_jetbrainsmono_nerd_font() {
  case "$(uname -s)" in
  Darwin)
    command -v brew >/dev/null 2>&1 || {
      echo "Homebrew not found; install JetBrains Mono Nerd Font manually (see README)."
      return 0
    }
    brew list --cask font-jetbrains-mono-nerd-font &>/dev/null && return 0
    brew install --cask font-jetbrains-mono-nerd-font
    echo 'Select "JetBrainsMono Nerd Font" (or similar) in Terminal -> Settings -> Profile -> Font.'
    ;;
  Linux)
    local dest="${HOME}/.local/share/fonts/jetbrains-mono-nerd"
    if [[ -d "${dest}" ]] && [[ -n "$(find "${dest}" -name '*.ttf' -print -quit 2>/dev/null)" ]]; then
      return 0
    fi
    # Same line must mention JetBrains and Nerd/NF (avoids false match across unrelated fonts)
    if command -v fc-list >/dev/null 2>&1; then
      if fc-list 2>/dev/null | grep -i jetbrains | grep -qiE 'nerd|[[:space:]]nf([[:space:]:]|$)'; then
        return 0
      fi
    fi
    command -v unzip >/dev/null 2>&1 || {
      echo "Install unzip to add JetBrains Mono Nerd Font, or install the font manually (see README)."
      return 0
    }
    mkdir -p "${dest}"
    local zip="${TMPDIR:-/tmp}/JetBrainsMono-${NERD_FONTS_JETBRAINS_TAG}.zip"
    curl -fL --retry 3 -o "${zip}" \
      "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_JETBRAINS_TAG}/JetBrainsMono.zip"
    unzip -qo "${zip}" -d "${dest}"
    rm -f "${zip}"
    if command -v fc-cache >/dev/null 2>&1; then
      fc-cache -f "${HOME}/.local/share/fonts" 2>/dev/null || true
    fi
    echo "JetBrains Mono Nerd Font installed under ${dest} - pick it in your terminal font settings."
    ;;
  esac
}

install_packages_apt() {
  sudo apt-get update
  if maybe_distro_upgrade; then
    sudo apt-get upgrade -y
  fi
  sudo apt-get install -y \
    python3 python3-pip python3-venv zsh git curl ca-certificates \
    build-essential cmake make neovim tmux fzf ripgrep unzip zip \
    direnv wget gnupg lsb-release
  sudo apt-get install -y thefuck 2>/dev/null || true
  ensure_thefuck
  # Optional workstation extras (ignore if unavailable)
  sudo apt-get install -y nodejs golang postgresql nginx 2>/dev/null || true
  sudo apt-get autoremove -y
  sudo apt-get autoclean -y
}

install_packages_dnf() {
  if maybe_distro_upgrade; then
    sudo dnf upgrade -y
  fi
  sudo dnf install -y \
    python3 python3-pip neovim tmux zsh git curl fzf ripgrep fd unzip \
    gcc gcc-c++ make cmake direnv fontconfig
  sudo dnf install -y thefuck python3-thefuck 2>/dev/null || ensure_thefuck
}

install_packages_pacman() {
  if maybe_distro_upgrade; then
    sudo pacman -Syu --noconfirm
  else
    sudo pacman -Sy --noconfirm
  fi
  sudo pacman -S --needed --noconfirm \
    python python-pip neovim tmux zsh git curl fzf ripgrep fd base-devel cmake direnv \
    ttf-jetbrains-mono-nerd
  ensure_thefuck
}

install_packages_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  ensure_brew_in_path
  brew update
  if maybe_distro_upgrade; then
    brew upgrade || echo "Note: brew upgrade had failures; continuing with installs."
  fi
  brew install git neovim tmux python pynvim direnv thefuck
  brew list --cask font-jetbrains-mono-nerd-font &>/dev/null || brew install --cask font-jetbrains-mono-nerd-font
}

install_linux_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "Using apt-get (Debian/Ubuntu family)"
    install_packages_apt
  elif command -v dnf >/dev/null 2>&1; then
    echo "Using dnf (Fedora/RHEL family)"
    install_packages_dnf
  elif command -v pacman >/dev/null 2>&1; then
    echo "Using pacman (Arch family)"
    install_packages_pacman
  else
    echo "No supported package manager found (apt-get, dnf, or pacman)."
    echo "Skipping distro packages. Install git, curl, zsh, neovim, tmux, fzf, ripgrep, direnv, Python 3, then re-run or use README manual install."
  fi
}

install_dotfiles() {
  require_commands git curl

  cp "${DOTFILES_ROOT}/gitconfig" "${HOME}/.gitconfig"
  cp "${DOTFILES_ROOT}/git_commit_template.txt" "${HOME}/.git_commit_template"
  ensure_git_identity_file

  touch "${HOME}/.zshenv" "${HOME}/.zsh_profile" "${HOME}/.zshlogin" "${HOME}/.zshlogout"
  cp "${DOTFILES_ROOT}/zshrc" "${HOME}/.zshrc"

  mkdir -p "${HOME}/.config/nvim"
  cp "${DOTFILES_ROOT}/vimrc" "${HOME}/.config/nvim/init.vim"
  ln -sf "${HOME}/.config/nvim/init.vim" "${HOME}/.vimrc"

  if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
    export VISUAL=nvim
    ensure_nvim_python_tools
    nvim --headless "+PlugInstall" +qa || echo "Note: run: nvim +PlugInstall +qall"
  elif command -v vim >/dev/null 2>&1; then
    export EDITOR=vim
    export VISUAL=vim
    echo "Note: neovim not found; install neovim for this config (uses Lua)."
  fi

  if command -v chsh >/dev/null 2>&1 && command -v zsh >/dev/null 2>&1; then
    local zsh_path
    zsh_path="$(command -v zsh)"
    if [[ "$(basename "${SHELL:-}")" != "zsh" ]]; then
      chsh -s "${zsh_path}" || echo "Note: set login shell manually: chsh -s ${zsh_path}"
    fi
  fi

  ensure_jetbrainsmono_nerd_font
}

echo "Starting system setup from: ${DOTFILES_ROOT}"

case "$(uname -s)" in
Linux)
  echo "Linux detected"
  pause_until_enter
  install_linux_packages
  ensure_oh_my_zsh
  install_dotfiles
  ;;
Darwin)
  echo "macOS detected"
  pause_until_enter
  install_packages_brew
  ensure_oh_my_zsh
  install_dotfiles
  ;;
*)
  echo "Unsupported OS: $(uname -s)"
  echo "Copy configs manually (see README) after installing zsh, neovim, git, and dependencies."
  exit 1
  ;;
esac

exec zsh

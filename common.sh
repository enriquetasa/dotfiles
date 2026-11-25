# Stages shared by macos.sh and linux.sh. Source it after setting DIR to the repo root.
# shellcheck shell=bash

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

link_git_and_tmux() {
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
}

# Needs zsh, git and curl to exist.
install_oh_my_zsh() {
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
}

# Needs nvim to exist.
link_neovim_config() {
  mkdir -p "$HOME/.config"
  # Use the dotfiles-tracked config as the single source of truth.
  backup_and_link "$DIR/nvim" "$HOME/.config/nvim"
  # Install/sync plugins headlessly so the first real launch is ready to go
  # (over HTTPS, for the same reason as Oh My Zsh above).
  GIT_CONFIG_GLOBAL=/dev/null nvim --headless "+Lazy! sync" +qa || true
  log "Neovim installed and config symlinked. Set 'JetBrainsMono Nerd Font' as your terminal font."
}

set_default_shell() {
  if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    chsh -s "$(command -v zsh)" || true
  fi
}

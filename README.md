# dotfiles

Personal shell, Git, tmux, and Neovim configuration. The install scripts **symlink** the tracked configs into place, so editing a file in this repo updates your live config immediately.

## Clone and go

```bash
git clone <YOUR_REPO_URL> ~/.dotfiles
cd ~/.dotfiles
./macos.sh      # on macOS
./linux.sh      # on Debian/Ubuntu Linux
```

Each script is interactive: it pauses with "Press ENTER" before each stage (Oh My Zsh, package manager, CLI tooling, Neovim, default shell) so you can watch what it does. Existing files at a target path are backed up to `<file>.backup.<timestamp>` before the symlink is created.

On the first run the script creates `~/.config/git/config.local` from `git/config.local.example`. **Set your name and email there before committing** — it is intentionally machine-local and not tracked.

## What is here

| Path | Role |
|------|------|
| `macos.sh` | macOS bootstrap: Oh My Zsh, Homebrew, CLI tooling, Neovim + Nerd Font, default shell |
| `linux.sh` | Debian/Ubuntu (`apt`) bootstrap: same flow, downloads the Nerd Font manually |
| `zsh/zshrc` | Zsh + Oh My Zsh; plugins gated on whether `direnv` / `thefuck` exist |
| `zsh/zshenv` | Cheap env vars for every zsh: locale, colors, Homebrew/Python flags |
| `zsh/zshprofile` | Login-shell setup: PATH (Homebrew + Python), editor, umask, compiler flags, ssh-agent, tmux auto-attach |
| `git/gitconfig` | Shared Git settings; **identity** lives in `~/.config/git/config.local` |
| `git/config.local.example` | Template for your machine-local Git identity |
| `git/git_commit_template.txt` | Commit message template |
| `tmux/tmux.conf` | tmux configuration |
| `nvim/` | Neovim config (LazyVim, Lua) — symlinked to `~/.config/nvim` |
| `legacy/` | Older configs, kept for reference |
| `LICENSE` | GNU GPL v3+ (copyleft) |

All of the above (except the seeded `config.local`) are symlinked into your home directory, so the repo stays the single source of truth.

## Automated setup details

**macOS:** [Homebrew](https://brew.sh/) is installed if missing, then `git`, `tmux`, `python3`, `thefuck`, `direnv`, `neovim`, `node`, `ruby`, `fd`, `ripgrep`, `fzf`, and friends.

**Linux:** packages are installed with `apt` (Debian/Ubuntu). For other distros, install the equivalent packages yourself, then re-run the script — the symlinking steps still work.

After Neovim is installed, the script symlinks `nvim/` to `~/.config/nvim` and runs `nvim --headless "+Lazy! sync" +qa` so [LazyVim](https://www.lazyvim.org/) plugins are installed before your first launch. There is no vim-plug step — this config is pure Lua / lazy.nvim.

### tmux

`tmux/tmux.conf` is symlinked to `~/.tmux.conf`. `zsh/zshprofile` auto-attaches an interactive shell to a tmux session named `main` (creating it if needed), so new terminals drop straight into tmux. Remove that block in `zsh/zshprofile` if you'd rather start tmux manually.

### Terminal font (JetBrains Mono Nerd Font)

The scripts install a **Nerd Font** build of **JetBrains Mono** so powerline-style symbols render correctly:

- **macOS:** Homebrew cask `font-jetbrains-mono-nerd-font`.
- **Linux:** the latest `JetBrainsMono.zip` from the [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases) is unpacked into `~/.local/share/fonts/` and the cache is refreshed with `fc-cache`.

Then select that font in your terminal profile (e.g. **Terminal.app** → Settings → Profiles → Font; **GNOME Terminal** → Preferences → profile → Custom font). The picker name is usually **"JetBrainsMono Nerd Font"** or **"JetBrainsMono NF"**.

## Manual install

If you don't want to run the full script, symlink the pieces you want:

```bash
DOTFILES="$PWD"   # run from the repo root

ln -sf "$DOTFILES/zsh/zshenv"    ~/.zshenv
ln -sf "$DOTFILES/zsh/zshprofile" ~/.zprofile
ln -sf "$DOTFILES/zsh/zshrc"     ~/.zshrc

ln -sf "$DOTFILES/git/gitconfig"             ~/.gitconfig
ln -sf "$DOTFILES/git/git_commit_template.txt" ~/.git_commit_template
mkdir -p ~/.config/git
cp "$DOTFILES/git/config.local.example" ~/.config/git/config.local
# edit ~/.config/git/config.local — set name and email

ln -sf "$DOTFILES/tmux/tmux.conf" ~/.tmux.conf

ln -sf "$DOTFILES/nvim" ~/.config/nvim
nvim --headless "+Lazy! sync" +qa
```

**Font (manual):** macOS: `brew install --cask font-jetbrains-mono-nerd-font`. Linux: download `JetBrainsMono.zip` from the [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases), unpack into `~/.local/share/fonts/`, and run `fc-cache -f`.

Use a recent Neovim (0.9+) — the config is Lua-based and built on LazyVim.

## License

Copyright © 2026 Enrique Tasa. Licensed under the **GNU General Public License v3.0 or later**. See [`LICENSE`](LICENSE) for the full terms.

## What "clone and go" still assumes

- **sudo** where the package manager needs it (Linux; `chsh` may prompt for your password).
- A network connection for package managers, Oh My Zsh, LazyVim plugin sync, and the font download.
- You still **select the installed Nerd Font** in your terminal emulator's settings — the script can't flip that for every app.
- **SSH keys / Git hosting auth** are yours to configure; this repo only rewrites `https://github.com/` to `ssh://git@github.com/` in Git config.

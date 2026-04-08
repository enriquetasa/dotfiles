# dotfiles

Personal shell, Git, and Neovim configuration. Paths and tooling follow XDG-style locations and **what is on your `PATH`**, not a single vendor OS.

## Clone and go

```bash
git clone <YOUR_REPO_URL> ~/.dotfiles
cd ~/.dotfiles
chmod +x setup.sh
./setup.sh
```

Non-interactive (no “Press Enter”, good for scripts / cloud-init):

```bash
DOTFILES_NONINTERACTIVE=1 ./setup.sh
```

Full system / Homebrew upgrades (everything on the box, not just these tools) are **off by default**. To run them:

```bash
DOTFILES_FULL_UPGRADE=1 ./setup.sh
```

Set Git identity without editing a file (optional):

```bash
GIT_AUTHOR_NAME='Your Name' GIT_AUTHOR_EMAIL='you@example.com' ./setup.sh
```

The first run creates `~/.config/git/config.local` from `git/config.local.example` if that file does not exist. **Change name and email there** (or use the env vars above) before making commits.

## What is here

| File | Role |
|------|------|
| `setup.sh` | Installs packages when it can, Oh My Zsh, Git/zsh/nvim configs, Python tools for Neovim, `PlugInstall` |
| `gitconfig` | Shared Git settings; **identity** lives in `~/.config/git/config.local` (see `git/config.local.example`) |
| `zshrc` | Zsh + optional Oh My Zsh plugins when `direnv` / `thefuck` exist |
| `vimrc` | Neovim: `stdpath('data')` for plugins, `stdpath('state')` for undo/backup/swap |
| `git_commit_template.txt` | Commit message template |
| `LICENSE` | GNU GPL v3+ (full text; copyleft) |
| `legacy/` | Older configs |

## Automated setup details

**Linux:** `apt-get`, `dnf`, or `pacman` (first match). If none match, package installs are skipped; you still need `git`, `curl`, `zsh`, `neovim`, etc. for a full setup.

**macOS:** [Homebrew](https://brew.sh/) (installed if missing).

`thefuck` is installed from the distro when possible; otherwise `pip3 install --user` is tried.

After Neovim is available, **`pynvim`**, **`black`**, and **`isort`** are installed with `pip3` (user site) so Python-related editor features match your `vimrc`.

### Terminal font (JetBrains Mono Nerd Font)

Setup installs a **Nerd Font** build of **JetBrains Mono** so powerline-style symbols (e.g. airline) render correctly:

- **macOS:** Homebrew cask `font-jetbrains-mono-nerd-font`.
- **Arch (pacman):** package `ttf-jetbrains-mono-nerd`.
- **Other Linux:** fonts are unpacked under `~/.local/share/fonts/jetbrains-mono-nerd/` and the font cache is refreshed with `fc-cache` when available.

Then choose that font in your terminal profile (e.g. **Terminal.app** → Settings → Profiles → Font; **GNOME Terminal** → Preferences → profile → Custom font). The picker name is usually along the lines of **“JetBrainsMono Nerd Font”** or **“JetBrainsMono NF”**.

## License

Copyright © 2026 Enrique Tasa. This repository is licensed under the **GNU General Public License v3.0 or later**. See [`LICENSE`](LICENSE) for the full terms (copyleft).

## Manual install

```bash
cp zshrc ~/.zshrc
mkdir -p ~/.config/git ~/.config/nvim
cp git/config.local.example ~/.config/git/config.local
# edit ~/.config/git/config.local — set name and email
cp gitconfig ~/.gitconfig
cp git_commit_template.txt ~/.git_commit_template
cp vimrc ~/.config/nvim/init.vim
ln -sf ~/.config/nvim/init.vim ~/.vimrc
pip3 install --user pynvim 'black>=24' 'isort>=5'
nvim +PlugInstall +qall
```

**Font (manual):** macOS: `brew install --cask font-jetbrains-mono-nerd-font`. Arch: `sudo pacman -S ttf-jetbrains-mono-nerd`. Else: same zip URL as in `setup.sh` (`NERD_FONTS_JETBRAINS_TAG` + `JetBrainsMono.zip` from [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases)), unpack under `~/.local/share/fonts/` and run `fc-cache -f ~/.local/share/fonts`.

Use a recent Neovim with Lua (`mini.pairs`).

## Environment overrides (optional)

| Variable | Effect |
|----------|--------|
| `DOTFILES_NONINTERACTIVE` | If set, skip the “Press Enter” pause |
| `DOTFILES_FULL_UPGRADE` | If set, run `apt-get upgrade` / `dnf upgrade` / `pacman -Syu` / `brew upgrade` (otherwise only install/sync what this script needs) |
| `GIT_AUTHOR_NAME` / `GIT_AUTHOR_EMAIL` | Written to `~/.config/git/config.local` on first run when that file is missing |
| `PYTHON_GLOBAL_OVERRIDE` / `PIP_GLOBAL_OVERRIDE` | Force `PYTHON_GLOBAL` / `PIP_GLOBAL` in zsh |
| `DOTFILES_NVIM_PYTHON3` | Python 3 binary for Neovim if set before launching `nvim` |
| `PYTHON_GLOBAL` | If exported before `nvim`, preferred over `python3` on `PATH` for `g:python3_host_prog` |

## Upgrading from an older `gitconfig` with `[user]` in-repo

If you previously committed `name` / `email` inside `gitconfig`, move them into `~/.config/git/config.local`:

```ini
[user]
	name = Your Name
	email = you@example.com
```

Keep `gitconfig` in the repo without a `[user]` section so the repo stays safe to publish.

## Migrating Neovim layout

- vim-plug and plugins live under **`stdpath('data')`** (often `~/.local/share/nvim/plugged`).
- Undo/backup/swap use **`stdpath('state')`** on Neovim 0.8+ (often `~/.local/state/nvim/...`).

Run `nvim +PlugInstall +qall` after updating.

## What “clone and go” still assumes

- **sudo** where the package manager needs it (Linux; `chsh` may prompt for your password).
- A network connection for package managers, Oh My Zsh, vim-plug, font downloads (non-Arch Linux), and `PlugInstall`.
- You still **select the installed Nerd Font** in your terminal emulator’s settings (the script cannot flip that for every app).
- **SSH keys / Git hosting auth** are yours to configure; this repo only rewrites `https://github.com/` to `ssh://git@github.com/` in Git config.

# Software Engineering Audit — dotfiles

- **Audited:** 2026-07-11, on branch `master` (pulled same day)
- **What it is:** Personal shell/Git/tmux/Neovim configuration with interactive bootstrap scripts for macOS (`macos.sh`) and Debian/Ubuntu (`linux.sh`). Configs are symlinked into place; a `legacy/` folder preserves the previous bash-based setup.
- **Size:** ~32 files. Personal tooling, no service, no deployment.

## Scorecard

| Dimension | Rating | Summary |
|---|---|---|
| Code quality | Good | `set -euo pipefail`, timestamped backups before every symlink, idempotent checks |
| Maintainability | Good | Clear README with per-file roles; machine-local git identity kept out of the repo |
| Security | Good | No secrets tracked; identity in untracked `config.local`; scripts pause before each stage |
| Complexity balance | Good | Appropriately minimal |

## Strengths (keep these patterns)

- `backup_and_link` backs up any existing file to `<file>.backup.<timestamp>` before symlinking — non-destructive by construction.
- Git identity is deliberately machine-local (`~/.config/git/config.local` seeded from a tracked example) — the right way to avoid committing personal email/name into shared machines.
- Interactive "Press ENTER" gates before each install stage make the script auditable as it runs.

## Findings (all minor — this repo is healthy)

### 1. LOW — Upstream installers are piped from the network
**Where:** `macos.sh` (Oh My Zsh, Homebrew installers via `curl ... | sh`).
**What:** Standard practice for these tools and acceptable for a personal machine; just be aware each run trusts upstream `master`/`HEAD`.
**How to fix:** Nothing required. If you want marginal hardening, pin the Oh My Zsh installer to a commit SHA in the raw URL.

### 2. LOW — No CI/lint
**How to fix (optional):** A single GitHub Action running `shellcheck macos.sh linux.sh` would catch quoting regressions cheaply. Skip anything heavier.

### 3. LOW — `legacy/` folder
**What:** `legacy/` (old bashrc/vimrc/setup.sh) is dead weight once the zsh/nvim setup is trusted.
**How to fix:** Delete it when confident; git history preserves it. Not urgent.

## What NOT to do

- Don't adopt a dotfiles framework (chezmoi, stow, etc.) — the current two-script approach is smaller than the frameworks' learning curve and works.

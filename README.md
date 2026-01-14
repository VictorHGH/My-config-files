# Dotfiles

Personal development environment configuration managed with GNU Stow.

## What's included
- Zsh + oh-my-zsh, aliases, and plugins
- tmux/oh-my-tmux and tmuxinator templates
- Neovim/Lua tooling and linters
- Homebrew and pacman package manifests
- Helper scripts for setup and maintenance

## Prerequisites
- `stow`, `zsh`, `tmux`, `tmuxinator`
- macOS or Linux with package manager (Homebrew/pacman)
- `git` and common build tools if you install dev packages

## Quick start
1. Clone into `~/dotfiles`.
2. From `~/dotfiles`, stow the configs you need:
   - macOS: `stow global` and any app-specific dirs.
   - Arch/Linux: `stow arch global` (or select subfolders).
3. Restart the shell to load zsh/tmux defaults.

## Package manifests
- Homebrew: `resources/homebrew/Brewfile` (macOS) and `resources/homebrew/Brewfile-linux` (Linux).
- Pacman: regenerate with `sudo pacman -Qqe > resources/pacman/packages.txt`.

## Scripts
- `scripts/upgrade.sh` — updates Oh My Zsh, Homebrew, npm, and Neovim; on Linux also runs `sudo pacman -Syu` and refreshes manifests. Review before running.
- `scripts/projects.zsh` — tmuxinator launcher/cleaner with `fzf` UI for managing YAML links.
- `scripts/treecat.py` — exports directory trees and file contents (avoid running in folders containing secrets).

## Tmuxinator templates
- `tmuxinator/start.zsh` scaffolds per-project configs and symlinks them into `~/.config/tmuxinator`.
- `tmuxinator/template.yml` and `tmuxinator/variables.zsh` act as the base; `move_windows.zsh` automates placing browser windows.

## Notes
- Keep `.stow-local-ignore` patterns intact to avoid stowing resources/scripts unintentionally.
- Always sanity-check package lists and scripts before running them on new machines.

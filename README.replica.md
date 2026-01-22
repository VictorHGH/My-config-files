# Dotfiles

Personal development environment configuration managed with GNU Stow.

## What's included
- Zsh + oh-my-zsh, aliases, and plugins
- tmux/oh-my-tmux and tmuxinator templates
- Neovim/Lua tooling and linters
- Homebrew and pacman package manifests
- Helper scripts for setup and maintenance

## Repository layout
- `global/`: cross-platform dotfiles stowed into `$HOME` (zsh, git, tmux local config, Neovim).
- `arch/`: Arch-only configs stowed into `$HOME` (i3, i3status).
- `resources/`: package manifests (not stowed).
- `scripts/`: setup and maintenance helpers (not stowed).
- `tmuxinator/`: templates and scaffolding helpers (not stowed).

## Prerequisites
- `stow`, `zsh`, `tmux`, `tmuxinator`
- macOS or Linux with a package manager (Homebrew/pacman)
- `git` and common build tools if you install dev packages

## Quick start
1. Clone into `~/dotfiles`.
2. From `~/dotfiles`, stow the configs you need:
   - macOS: `stow global` and any app-specific dirs.
   - Arch/Linux: `stow arch global` (or select subfolders).
3. Restart the shell to load zsh/tmux defaults.

## Replicate on a new machine
1. Install base tools: `git`, `stow`, `zsh`, `tmux`, `tmuxinator`, `neovim`.
2. Install packages from manifests:
   - macOS: `brew bundle --file resources/homebrew/Brewfile`
   - Linuxbrew: `brew bundle --file resources/homebrew/Brewfile-linux`
   - Arch: `sudo pacman -S --needed - < resources/pacman/packages.txt`
3. Install oh-my-zsh and required plugins (see `.zshrc` plugin lists).
4. Install gpakosz tmux (oh-my-tmux) and keep `.tmux.conf.local` from this repo:
   - Clone https://github.com/gpakosz/.tmux to `~/.tmux`
   - Symlink `~/.tmux/.tmux.conf` to `~/.tmux.conf`
5. Clone this repo into `~/dotfiles` and run `stow` from there.
6. Set zsh as the default shell (`chsh -s $(which zsh)`) if needed.
7. Open Neovim once to let `lazy.nvim` bootstrap plugins, then run `:Lazy sync`.
8. Use `tmuxinator/start.zsh` to scaffold per-project tmuxinator configs.

## Machine-specific tweaks
- Update `global/.gitconfig` with your name/email.
- Verify `global/.zshrc` paths and aliases match your home directory.
- Ensure `$USERNAME` is set (or switch to `$USER`) so oh-my-zsh paths resolve.
- Adjust Linux-only commands in `.zshrc` (`setxkbmap`, `xinput`) for new hardware.

## Package manifests
- Homebrew: `resources/homebrew/Brewfile` (macOS) and `resources/homebrew/Brewfile-linux` (Linux).
- Pacman: regenerate with `sudo pacman -Qqe > resources/pacman/packages.txt`.

## Scripts
- `scripts/upgrade.sh` updates Oh My Zsh, Homebrew, npm, and Neovim; on Linux also runs `sudo pacman -Syu` and refreshes manifests. Review before running.
- `scripts/projects.zsh` is a tmuxinator launcher/cleaner with an `fzf` UI for managing YAML links.
- `scripts/treecat.py` exports directory trees and file contents (avoid running in folders containing secrets).

## Tmuxinator templates
- `tmuxinator/start.zsh` scaffolds per-project configs and symlinks them into `~/.config/tmuxinator`.
- `tmuxinator/template.yml` and `tmuxinator/variables.zsh` act as the base; `move_windows.zsh` automates placing browser windows.

## Notes
- Keep `.stow-local-ignore` patterns intact to avoid stowing resources/scripts unintentionally.
- Always sanity-check package lists and scripts before running them on new machines.

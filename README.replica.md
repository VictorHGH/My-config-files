# Dotfiles

Personal development environment configuration managed with GNU Stow.

## What's included
- Zsh + oh-my-zsh, aliases, and plugins
- Neovim/Lua tooling and linters
- Homebrew, pacman, and Termux package manifests
- Helper scripts for setup and maintenance

## Repository layout
- `global/`: cross-platform dotfiles stowed into `$HOME` (zsh, git, Neovim).
- `arch/`: Arch desktop host overrides (i3/i3status).
- `macbook_pro/`: Arch MacBook host overrides (i3/i3status).
- `resources/`: package manifests (not stowed).
- `scripts/`: setup and maintenance helpers (not stowed).

## Prerequisites
- `stow`, `zsh`, `neovim`
- macOS or Linux with a package manager (Homebrew/pacman)
- `git` and common build tools if you install dev packages

## Quick start
1. Run bootstrap with a profile:
   - `./scripts/bootstrap.sh --profile arch-desktop`
   - `./scripts/bootstrap.sh --profile arch-macbook`
   - `./scripts/bootstrap.sh --profile mac-mini`
   - `./scripts/bootstrap.sh --profile termux`
2. Or stow manually from `~/dotfiles` if needed.
3. Restart the shell to load zsh defaults.

## Replicate on a new machine
1. Install base tools: `git`, `stow`, `zsh`, `neovim`.
2. Install packages from manifests:
    - macOS: `brew bundle --file resources/homebrew/Brewfile`
    - Linuxbrew: `brew bundle --file resources/homebrew/Brewfile-linux`
    - Arch: `sudo pacman -S --needed - < resources/pacman/packages.txt`
    - Termux: `xargs pkg install -y < resources/termux/packages.txt`
3. Install oh-my-zsh and required plugins (see `.zshrc` plugin lists).
4. Clone this repo into `~/dotfiles` and run `stow` from there.
5. Set zsh as the default shell (`chsh -s $(which zsh)`) if needed.
6. Open Neovim once to let `lazy.nvim` bootstrap plugins, then run `:Lazy sync`.

## Machine-specific tweaks
- Update `global/.gitconfig` with your name/email.
- Verify `global/.zshrc` paths and aliases match your home directory.
- Adjust Linux-only commands in `.zshrc` (`setxkbmap`, `xinput`) for new hardware.

## Package manifests
- Homebrew: `resources/homebrew/Brewfile` (macOS) and `resources/homebrew/Brewfile-linux` (Linux).
- Pacman: regenerate with `sudo pacman -Qqe > resources/pacman/packages.txt`.
- Termux: edit `resources/termux/packages.txt`.

## Scripts
- `scripts/bootstrap.sh` provisions a new host (base packages, stow modules, package manifest install, installs Oh My Zsh if missing, and sets zsh as default shell).
- Safe test mode: `./scripts/bootstrap.sh --profile arch-desktop --no-base-tools --no-packages --no-shell --no-update`
- `scripts/upgrade.sh` updates Oh My Zsh, Homebrew, npm, and Neovim; on Linux also runs `sudo pacman -Syu` and refreshes manifests. Review before running.
- `scripts/treecat.py` exports directory trees and file contents (avoid running in folders containing secrets).

## i3 layout
- Shared config: `resources/i3/config.shared`
- Arch desktop host file: `arch/.config/i3/config.host.conf`
- Arch MacBook host file: `macbook_pro/.config/i3/config.host.conf`

## Add a new profile/OS
1. Create a host folder (example: `work_laptop/.config/i3/`) with `config` and `config.host.conf`.
2. Add the profile mapping in `scripts/bootstrap.sh` and define stow modules.
3. If needed, add package manifests under `resources/` and wire them in `bootstrap.sh`.
4. Document the new profile in Quick start profile examples.

## Notes
- Keep `.stow-local-ignore` patterns intact to avoid stowing resources/scripts unintentionally.
- Always sanity-check package lists and scripts before running them on new machines.

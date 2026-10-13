#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-git@github.com:VictorHGH/My-config-files.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

PROFILE="auto"
INSTALL_BASE_TOOLS=1
INSTALL_PACKAGES=1
SET_ZSH_DEFAULT=1
UPDATE_DOTFILES=1
INSTALL_SYSTEM_FIXES=0
DRY_RUN=0

PACMAN_FILE="resources/pacman/packages.txt"
AUR_FILE="resources/aur/packages.txt"
BREWFILE_MAC="resources/homebrew/Brewfile"
TERMUX_FILE="resources/termux/packages.txt"
EARLY_KBD_SCRIPT_FILE="scripts/ensure-early-kbd.sh"
EARLY_KBD_HOOK_FILE="resources/pacman/hooks/95-early-kbd.hook"
AUDIO_HDA_MODPROBE_FILE="resources/modprobe/99-snd-hda-intel.conf"

STOW_MODULES=()

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [options]

Options:
  --profile <name>     Profile: auto|arch|mac-mini|termux
  --repo <url>         Dotfiles repo URL (default: VictorHGH/My-config-files)
  --dir <path>         Dotfiles target directory (default: ~/dotfiles)
  --no-base-tools      Skip base tool installation step
  --no-packages        Skip package manifest installation
  --system-fixes       Apply Arch-specific LUKS keyboard and audio fixes
  --no-shell           Skip setting zsh as default shell
  --no-update          Do not git pull if dotfiles dir already exists
  --dry-run            Show the actions without changing the system
  -h, --help           Show this help

Examples:
  ./scripts/bootstrap.sh --profile arch
  ./scripts/bootstrap.sh --profile mac-mini
  ./scripts/bootstrap.sh --profile termux
  ./scripts/bootstrap.sh --profile arch --dry-run
EOF
}

log() {
  printf '[bootstrap] %s\n' "$*"
}

warn() {
  printf '[bootstrap][warn] %s\n' "$*" >&2
}

die() {
  printf '[bootstrap][error] %s\n' "$*" >&2
  exit 1
}

have() {
  command -v "$1" >/dev/null 2>&1
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        PROFILE="$2"
        shift 2
        ;;
      --repo)
        DOTFILES_REPO="$2"
        shift 2
        ;;
      --dir)
        DOTFILES_DIR="$2"
        shift 2
        ;;
      --no-packages)
        INSTALL_PACKAGES=0
        shift
        ;;
      --no-system-fixes)
        INSTALL_SYSTEM_FIXES=0
        shift
        ;;
      --system-fixes)
        INSTALL_SYSTEM_FIXES=1
        shift
        ;;
      --no-base-tools)
        INSTALL_BASE_TOOLS=0
        shift
        ;;
      --no-shell)
        SET_ZSH_DEFAULT=0
        shift
        ;;
      --no-update)
        UPDATE_DOTFILES=0
        shift
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown argument: $1"
        ;;
    esac
  done
}

detect_platform() {
  if [[ -n "${TERMUX_VERSION:-}" ]] || [[ "${PREFIX:-}" == "/data/data/com.termux/files/usr" ]]; then
    echo "termux"
    return
  fi

  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)
      if have pacman; then
        echo "arch"
      else
        echo "linux"
      fi
      ;;
    *) echo "unknown" ;;
  esac
}

normalize_profile() {
  local platform="$1"

  if [[ "$PROFILE" == "auto" ]]; then
    case "$platform" in
      arch) PROFILE="arch" ;;
      macos) PROFILE="mac-mini" ;;
      termux) PROFILE="termux" ;;
      *) die "Cannot auto-detect profile for platform '$platform'. Use --profile." ;;
    esac
  fi

  case "$PROFILE" in
    arch)
      STOW_MODULES=(global arch)
      ;;
    mac-mini)
      STOW_MODULES=(global mac_mini)
      ;;
    termux)
      STOW_MODULES=(global)
      ;;
    *)
      die "Unknown profile '$PROFILE'"
      ;;
  esac
}

install_base_tools() {
  local platform="$1"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    case "$platform" in
      arch) log "Would run: sudo pacman -S --needed git stow zsh" ;;
      macos) log "Would run: brew install git stow zsh" ;;
      termux) log "Would run: pkg update -y && pkg install -y git stow zsh curl" ;;
      *) warn "No base tool installation is defined for $platform" ;;
    esac
    return
  fi

  case "$platform" in
    arch)
      log "Installing base tools with pacman"
      sudo pacman -S --needed git stow zsh
      ;;
    macos)
      if ! have brew; then
        die "Homebrew is not installed. Install brew first, then rerun bootstrap."
      fi
      log "Installing base tools with Homebrew"
      brew install git stow zsh
      ;;
    termux)
      if ! have pkg; then
        die "Termux pkg command not found."
      fi
      log "Installing base tools with Termux pkg"
      pkg update -y
      pkg install -y git stow zsh curl
      ;;
    linux)
      warn "Generic Linux detected (no pacman). Only stow step will run."
      ;;
    *)
      die "Unsupported platform '$platform'"
      ;;
  esac
}

clone_or_update_dotfiles() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ -d "$DOTFILES_DIR/.git" && "$UPDATE_DOTFILES" -eq 1 ]]; then
      log "Would run: git -C $DOTFILES_DIR pull --rebase"
    elif [[ ! -d "$DOTFILES_DIR" ]]; then
      log "Would run: git clone $DOTFILES_REPO $DOTFILES_DIR"
    else
      log "Would use existing dotfiles directory: $DOTFILES_DIR"
    fi
    return
  fi

  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    if [[ "$UPDATE_DOTFILES" -eq 1 ]]; then
      log "Updating existing dotfiles repo"
      git -C "$DOTFILES_DIR" pull --rebase
    else
      log "Skipping dotfiles update"
    fi
    return
  fi

  if [[ -d "$DOTFILES_DIR" && ! -d "$DOTFILES_DIR/.git" ]]; then
    die "Directory '$DOTFILES_DIR' exists but is not a git repo"
  fi

  log "Cloning dotfiles repo"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
}

run_stow() {
  local host_modules=(arch mac_mini)
  local mod selected

  if [[ ! -d "$DOTFILES_DIR" ]]; then
    warn "Dotfiles directory does not exist; cannot preview Stow"
    return
  fi

  log "Cleaning conflicting host modules"
  (
    cd "$DOTFILES_DIR"
    for mod in "${host_modules[@]}"; do
      selected=0
      for chosen in "${STOW_MODULES[@]}"; do
        if [[ "$chosen" == "$mod" ]]; then
          selected=1
          break
        fi
      done
      if [[ "$selected" -eq 0 && -d "$mod" ]]; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
          stow -n -D "$mod" >/dev/null 2>&1 || true
        else
          stow -D "$mod" >/dev/null 2>&1 || true
        fi
      fi
    done
  )

  log "Applying stow modules: ${STOW_MODULES[*]}"
  (
    cd "$DOTFILES_DIR"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      stow -n -R "${STOW_MODULES[@]}"
    else
      stow -R "${STOW_MODULES[@]}"
    fi
  )
}

install_manifests() {
  local platform="$1"

  if [[ "$INSTALL_PACKAGES" -ne 1 ]]; then
    log "Skipping manifest package installation"
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    case "$platform" in
      arch) log "Would install $PACMAN_FILE and $AUR_FILE" ;;
      macos) log "Would run: brew bundle --file $BREWFILE_MAC" ;;
      termux) log "Would install $TERMUX_FILE" ;;
    esac
    return
  fi

  case "$platform" in
    arch)
      if [[ -f "$DOTFILES_DIR/$PACMAN_FILE" ]]; then
        log "Installing Arch packages from $PACMAN_FILE"
        sudo pacman -S --needed - < "$DOTFILES_DIR/$PACMAN_FILE"
      else
        warn "Missing $PACMAN_FILE"
      fi

      if [[ -f "$DOTFILES_DIR/$AUR_FILE" ]]; then
        install_aur_packages
      fi
      ;;
    macos)
      if [[ -f "$DOTFILES_DIR/$BREWFILE_MAC" ]]; then
        log "Installing macOS packages from Brewfile"
        brew bundle --file "$DOTFILES_DIR/$BREWFILE_MAC"
      else
        warn "Missing $BREWFILE_MAC"
      fi
      ;;
    termux)
      if [[ -f "$DOTFILES_DIR/$TERMUX_FILE" ]]; then
        log "Installing Termux packages from $TERMUX_FILE"
        while IFS= read -r pkg; do
          [[ -z "$pkg" || "$pkg" == \#* ]] && continue
          if ! pkg install -y "$pkg"; then
            warn "Could not install Termux package '$pkg'"
          fi
        done < "$DOTFILES_DIR/$TERMUX_FILE"
      else
        warn "Missing $TERMUX_FILE"
      fi
      ;;
  esac
}

install_aur_packages() {
  local yay_dir

  if ! have yay; then
    log "Installing yay"
    sudo pacman -S --needed base-devel
    yay_dir="$(mktemp -d)"
    trap 'rm -rf "$yay_dir"' RETURN
    git clone https://aur.archlinux.org/yay.git "$yay_dir/yay"
    (
      cd "$yay_dir/yay"
      makepkg -si --noconfirm
    )
    trap - RETURN
    rm -rf "$yay_dir"
  fi

  log "Installing AUR packages from $AUR_FILE"
  yay -S --needed - < "$DOTFILES_DIR/$AUR_FILE"
}

install_arch_system_fixes() {
  local platform="$1"

  if [[ "$platform" != "arch" ]]; then
    return
  fi

  if [[ "$INSTALL_SYSTEM_FIXES" -ne 1 ]]; then
    log "Skipping Arch system fixes"
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Would install the Arch LUKS keyboard and audio fixes"
    return
  fi

  local src_script="$DOTFILES_DIR/$EARLY_KBD_SCRIPT_FILE"
  local src_hook="$DOTFILES_DIR/$EARLY_KBD_HOOK_FILE"
  local src_audio_modprobe="$DOTFILES_DIR/$AUDIO_HDA_MODPROBE_FILE"

  if [[ ! -f "$src_script" ]]; then
    warn "Missing $EARLY_KBD_SCRIPT_FILE"
    return
  fi

  if [[ ! -f "$src_hook" ]]; then
    warn "Missing $EARLY_KBD_HOOK_FILE"
    return
  fi

  if [[ ! -f "$src_audio_modprobe" ]]; then
    warn "Missing $AUDIO_HDA_MODPROBE_FILE"
    return
  fi

  if [[ "$EUID" -ne 0 ]]; then
    if ! have sudo; then
      warn "sudo not found; skipping Arch system fixes"
      return
    fi

    if ! sudo -n true >/dev/null 2>&1; then
      if [[ -t 0 ]]; then
        log "sudo credentials required for Arch system fixes"
        if ! sudo -v; then
          warn "Could not obtain sudo credentials; skipping Arch system fixes"
          return
        fi
      else
        warn "No interactive TTY for sudo; skipping Arch system fixes"
        return
      fi
    fi
  fi

  log "Installing early boot keyboard fix"
  if [[ "$EUID" -eq 0 ]]; then
    install -Dm755 "$src_script" /usr/local/sbin/ensure-early-kbd
    install -Dm644 "$src_hook" /etc/pacman.d/hooks/95-early-kbd.hook
    if ! /usr/local/sbin/ensure-early-kbd --rebuild; then
      warn "ensure-early-kbd failed; run it manually"
    fi

    log "Installing audio jack startup fix"
    install -Dm644 "$src_audio_modprobe" /etc/modprobe.d/99-snd-hda-intel.conf
    if [[ -e /sys/module/snd_hda_intel/parameters/power_save ]]; then
      printf '%s\n' 0 > /sys/module/snd_hda_intel/parameters/power_save || true
    fi
    if [[ -e /sys/module/snd_hda_intel/parameters/power_save_controller ]]; then
      printf '%s\n' N > /sys/module/snd_hda_intel/parameters/power_save_controller || true
    fi
  else
    sudo install -Dm755 "$src_script" /usr/local/sbin/ensure-early-kbd
    sudo install -Dm644 "$src_hook" /etc/pacman.d/hooks/95-early-kbd.hook
    if ! sudo /usr/local/sbin/ensure-early-kbd --rebuild; then
      warn "ensure-early-kbd failed; run it manually"
    fi

    log "Installing audio jack startup fix"
    sudo install -Dm644 "$src_audio_modprobe" /etc/modprobe.d/99-snd-hda-intel.conf
    if [[ -e /sys/module/snd_hda_intel/parameters/power_save ]]; then
      printf '%s\n' 0 | sudo tee /sys/module/snd_hda_intel/parameters/power_save >/dev/null || true
    fi
    if [[ -e /sys/module/snd_hda_intel/parameters/power_save_controller ]]; then
      printf '%s\n' N | sudo tee /sys/module/snd_hda_intel/parameters/power_save_controller >/dev/null || true
    fi
  fi
}

install_oh_my_zsh() {
  if [[ -s "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
    log "Oh My Zsh already installed"
    return
  fi

  warn "Oh My Zsh is not installed; install and review it manually before using its plugins"
}

set_zsh_default() {
  local platform="$1"

  if [[ "$SET_ZSH_DEFAULT" -ne 1 ]]; then
    log "Skipping default shell setup"
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Would set zsh as the default shell"
    return
  fi

  if ! have zsh; then
    warn "zsh not found after bootstrap"
    return
  fi

  local zsh_bin
  zsh_bin="$(command -v zsh)"

  if [[ "${SHELL:-}" == "$zsh_bin" ]]; then
    log "zsh is already the default shell"
    return
  fi

  if have chsh; then
    if chsh -s "$zsh_bin" "$USER"; then
      log "Default shell changed to zsh. Log out and back in."
      return
    fi
    warn "chsh failed; set the default shell manually"
  else
    warn "chsh not available"
  fi

  if [[ "$platform" == "termux" ]]; then
    warn "In Termux, run: chsh -s zsh"
  else
    warn "Set shell manually with: chsh -s $zsh_bin"
  fi
}

main() {
  parse_args "$@"

  local platform
  platform="$(detect_platform)"

  normalize_profile "$platform"

  log "Platform: $platform"
  log "Profile: $PROFILE"
  log "Dotfiles dir: $DOTFILES_DIR"

  if [[ "$INSTALL_BASE_TOOLS" -eq 1 ]]; then
    install_base_tools "$platform"
  else
    log "Skipping base tool installation"
  fi
  clone_or_update_dotfiles
  run_stow
  install_manifests "$platform"
  install_arch_system_fixes "$platform"
  install_oh_my_zsh
  set_zsh_default "$platform"

  log "Bootstrap complete"
}

main "$@"

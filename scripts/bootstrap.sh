#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-git@github.com:VictorHGH/My-config-files.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

PROFILE="auto"
INSTALL_BASE_TOOLS=1
INSTALL_PACKAGES=1
SET_ZSH_DEFAULT=1
UPDATE_DOTFILES=1

PACMAN_FILE="resources/pacman/packages.txt"
BREWFILE_MAC="resources/homebrew/Brewfile"
TERMUX_FILE="resources/termux/packages.txt"

STOW_MODULES=()

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [options]

Options:
  --profile <name>     Profile: auto|arch-desktop|arch-macbook|work-pc|mac-mini|termux
  --repo <url>         Dotfiles repo URL (default: VictorHGH/My-config-files)
  --dir <path>         Dotfiles target directory (default: ~/dotfiles)
  --no-base-tools      Skip base tool installation step
  --no-packages        Skip package manifest installation
  --no-shell           Skip setting zsh as default shell
  --no-update          Do not git pull if dotfiles dir already exists
  -h, --help           Show this help

Examples:
  ./scripts/bootstrap.sh --profile arch-desktop
  ./scripts/bootstrap.sh --profile arch-macbook
  ./scripts/bootstrap.sh --profile mac-mini
  ./scripts/bootstrap.sh --profile termux
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
      arch) PROFILE="arch-desktop" ;;
      macos) PROFILE="mac-mini" ;;
      termux) PROFILE="termux" ;;
      *) die "Cannot auto-detect profile for platform '$platform'. Use --profile." ;;
    esac
  fi

  case "$PROFILE" in
    arch-desktop|work-pc)
      STOW_MODULES=(global arch)
      ;;
    arch-macbook|macbook-pro)
      STOW_MODULES=(global macbook_pro)
      ;;
    mac-mini|macos)
      STOW_MODULES=(global mac_mini)
      ;;
    termux|redmi-a5)
      STOW_MODULES=(global)
      ;;
    *)
      die "Unknown profile '$PROFILE'"
      ;;
  esac
}

install_base_tools() {
  local platform="$1"

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
  local host_modules=(arch macbook_pro mac_mini)
  local mod selected

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
        stow -D "$mod" >/dev/null 2>&1 || true
      fi
    done
  )

  log "Applying stow modules: ${STOW_MODULES[*]}"
  (
    cd "$DOTFILES_DIR"
    stow -R "${STOW_MODULES[@]}"
  )
}

install_manifests() {
  local platform="$1"

  if [[ "$INSTALL_PACKAGES" -ne 1 ]]; then
    log "Skipping manifest package installation"
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

install_oh_my_zsh() {
  local installer_url="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

  if [[ -s "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
    log "Oh My Zsh already installed"
    return
  fi

  if ! have zsh; then
    warn "zsh is required before installing Oh My Zsh"
    return
  fi

  if ! have git; then
    warn "git is required before installing Oh My Zsh"
    return
  fi

  log "Installing Oh My Zsh"

  if have curl; then
    if ! RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL "$installer_url")"; then
      warn "Oh My Zsh installation failed"
    fi
    return
  fi

  if have wget; then
    if ! RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(wget -qO- "$installer_url")"; then
      warn "Oh My Zsh installation failed"
    fi
    return
  fi

  warn "Neither curl nor wget found; cannot install Oh My Zsh automatically"
}

set_zsh_default() {
  local platform="$1"

  if [[ "$SET_ZSH_DEFAULT" -ne 1 ]]; then
    log "Skipping default shell setup"
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
  install_oh_my_zsh
  set_zsh_default "$platform"

  log "Bootstrap complete"
}

main "$@"

#!/usr/bin/env zsh
set -euo pipefail

# ----------------------------
# Config
# ----------------------------
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

PACMAN_LIST="$DOTFILES_DIR/resources/pacman/packages.txt"
BREWFILE_MAC="$DOTFILES_DIR/resources/homebrew/Brewfile"
BREWFILE_LINUX="$DOTFILES_DIR/resources/homebrew/Brewfile-linux"

# Packages to never remove in --strict mode (regex, one per line)
PACMAN_STRICT_PROTECT_REGEX=(
  '^base$'
  '^base-devel$'
  '^linux$'
  '^linux-lts$'
  '^linux-zen$'
  '^linux-headers$'
  '^linux-lts-headers$'
  '^linux-zen-headers$'
  '^amd-ucode$'
  '^intel-ucode$'
  '^mesa$'
  '^nvidia$'
  '^nvidia-lts$'
  '^nvidia-dkms$'
  '^networkmanager$'
  '^openssh$'
  '^sudo$'
  '^systemd$'
  '^glibc$'
  '^pacman$'
)

# ----------------------------
# CLI flags
# ----------------------------
DRY_RUN=0
STRICT=0
NO_GIT_PULL=0
NO_EXPORT=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --strict) STRICT=1 ;;
    --no-git-pull) NO_GIT_PULL=1 ;;
    --no-export) NO_EXPORT=1 ;;
    -h|--help)
      cat <<EOF
Usage: $0 [--dry-run] [--strict] [--no-git-pull] [--no-export]

--dry-run       Show what would be executed (best for first run)
--strict        On Linux: remove pacman packages not present in packages.txt (protected list applied)
--no-git-pull   Don't do 'git pull' in dotfiles (if dotfiles is a git repo)
--no-export     Don't rewrite packages.txt / Brewfile at the end
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      exit 1
      ;;
  esac
done

# ----------------------------
# Helpers
# ----------------------------
function hr() { echo "-----------------------"; }
function print_help() {
  hr
  echo "Upgrade $1"
  hr
}

function run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "+ $*"
  else
    eval "$@"
  fi
}

function have() { command -v "$1" >/dev/null 2>&1; }

function is_git_repo() {
  [[ -d "$DOTFILES_DIR/.git" ]]
}

function ensure_dotfiles_dir() {
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
  fi
}

function git_pull_dotfiles() {
  if [[ "$NO_GIT_PULL" -eq 1 ]]; then
    print_help "git pull (skipped)"
    return
  fi

  if is_git_repo; then
    print_help "git pull (dotfiles)"
    run "cd '$DOTFILES_DIR' && git pull --rebase"
  else
    print_help "git pull (dotfiles)"
    echo "Not a git repo: $DOTFILES_DIR (skipping)"
  fi
}

# ----------------------------
# Common upgrades
# ----------------------------
function upgrade_oh_my_zsh() {
  print_help "Oh My Zsh"
  if [[ -x "$HOME/.oh-my-zsh/tools/upgrade.sh" ]]; then
    run "zsh '$HOME/.oh-my-zsh/tools/upgrade.sh'"
  else
    echo "Oh My Zsh upgrade script not found (skipping)"
  fi
}

function upgrade_brew() {
  print_help "Homebrew"
  if have brew; then
    # Avoid `brew upgrade \`brew outdated\`` (fragile). Just `brew update && brew upgrade`.
    run "brew update"
    run "brew upgrade"
    run "brew cleanup"
    run "brew autoremove || true"
  else
    echo "brew not found (skipping)"
  fi
}

function upgrade_npm_global() {
  print_help "npm (global)"
  if have npm; then
    # Keep it simple; "sync" global npm packages across machines is usually not worth it.
    run "npm -g update || true"
  else
    echo "npm not found (skipping)"
  fi
}

function upgrade_nvim() {
  print_help "Neovim"
  if have nvim; then
    # Runs user command if you have it defined; otherwise won't crash your shell.
    run "nvim --headless '+silent! UpgradeNvim' '+qa' || true"
  else
    echo "nvim not found (skipping)"
  fi
}

# ----------------------------
# Linux: pacman sync + upgrade
# ----------------------------
function pacman_sync_install_missing() {
  print_help "pacman sync (install missing from packages.txt)"
  if [[ ! -f "$PACMAN_LIST" ]]; then
    echo "No packages list found at: $PACMAN_LIST (skipping install sync)"
    return
  fi

  # Filter comments/empty lines
  # pacman reads from stdin with '-'
  run "grep -vE '^\s*#|^\s*$' '$PACMAN_LIST' | sudo pacman -S --needed -"
}

function pacman_strict_remove_extras() {
  print_help "pacman strict (remove extras not in packages.txt)"
  if [[ "$STRICT" -ne 1 ]]; then
    echo "Strict mode disabled (skipping removals). Use --strict to enable."
    return
  fi
  if [[ ! -f "$PACMAN_LIST" ]]; then
    echo "No packages list found at: $PACMAN_LIST (cannot strict remove)"
    return
  fi

  # Build allowlist (desired) and current list
  local desired_tmp current_tmp extras_tmp protect_tmp
  desired_tmp="$(mktemp)"
  current_tmp="$(mktemp)"
  extras_tmp="$(mktemp)"
  protect_tmp="$(mktemp)"

  # desired
  grep -vE '^\s*#|^\s*$' "$PACMAN_LIST" | sort -u > "$desired_tmp"
  # current explicitly installed packages
  pacman -Qqe | sort -u > "$current_tmp"

  # extras = current - desired
  comm -23 "$current_tmp" "$desired_tmp" > "$extras_tmp"

  # Apply protection filters
  # Remove protected packages from extras list
  printf "%s\n" "${PACMAN_STRICT_PROTECT_REGEX[@]}" > "$protect_tmp"
  while read -r re; do
    [[ -z "$re" ]] && continue
    grep -vE "$re" "$extras_tmp" > "${extras_tmp}.new" || true
    mv "${extras_tmp}.new" "$extras_tmp"
  done < "$protect_tmp"

  if [[ ! -s "$extras_tmp" ]]; then
    echo "No extra packages to remove."
    rm -f "$desired_tmp" "$current_tmp" "$extras_tmp" "$protect_tmp"
    return
  fi

  echo "Packages to remove (after protection filters):"
  cat "$extras_tmp"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "(dry-run) Would run: sudo pacman -Rns - < extras"
  else
    echo
    echo "Removing extras..."
    sudo pacman -Rns - < "$extras_tmp"
  fi

  rm -f "$desired_tmp" "$current_tmp" "$extras_tmp" "$protect_tmp"
}

function pacman_upgrade() {
  print_help "pacman upgrade"
  run "sudo pacman -Syu"
}

# ----------------------------
# Brew bundle sync
# ----------------------------
function brew_bundle_sync_mac() {
  print_help "brew bundle sync (mac)"
  if ! have brew; then
    echo "brew not found (skipping brew bundle)"
    return
  fi
  if [[ -f "$BREWFILE_MAC" ]]; then
    run "brew bundle --file '$BREWFILE_MAC'"
  else
    echo "Brewfile not found: $BREWFILE_MAC (skipping)"
  fi
}

function brew_bundle_sync_linux() {
  print_help "brew bundle sync (linux)"
  if ! have brew; then
    echo "brew not found (skipping brew bundle)"
    return
  fi
  if [[ -f "$BREWFILE_LINUX" ]]; then
    run "brew bundle --file '$BREWFILE_LINUX'"
  else
    echo "Brewfile-linux not found: $BREWFILE_LINUX (skipping)"
  fi
}

# ----------------------------
# Export state back to dotfiles
# ----------------------------
function export_linux_state() {
  if [[ "$NO_EXPORT" -eq 1 ]]; then
    print_help "export (skipped)"
    return
  fi

  print_help "Export Linux package state"
  # Export explicit packages
  run "mkdir -p '$DOTFILES_DIR/resources/pacman'"
  run "sudo pacman -Qqe > '$PACMAN_LIST'"

  # Export brew bundle (linux)
  if have brew; then
    run "mkdir -p '$DOTFILES_DIR/resources/homebrew'"
    run "brew bundle dump --file '$BREWFILE_LINUX' --force"
    echo "Brewfile-linux created/updated"
  else
    echo "brew not found (skipping Brewfile-linux export)"
  fi
}

function export_mac_state() {
  if [[ "$NO_EXPORT" -eq 1 ]]; then
    print_help "export (skipped)"
    return
  fi

  print_help "Export macOS package state"
  if have brew; then
    run "mkdir -p '$DOTFILES_DIR/resources/homebrew'"
    run "brew bundle dump --file '$BREWFILE_MAC' --force"
    echo "Brewfile created/updated"
  else
    echo "brew not found (skipping Brewfile export)"
  fi
}

# ----------------------------
# Main flow
# ----------------------------
function common_flow() {
  upgrade_oh_my_zsh
  upgrade_brew
  upgrade_npm_global
  upgrade_nvim
  print_help "Finished common upgrades"
}

function linux_flow() {
  # 1) pull dotfiles state
  git_pull_dotfiles

  # 2) sync local machine to dotfiles (install missing, optionally remove extras)
  pacman_sync_install_missing
  pacman_strict_remove_extras

  # 3) upgrade system
  pacman_upgrade

  # 4) brew bundle sync + upgrade (if you use brew on linux)
  brew_bundle_sync_linux
  upgrade_brew

  # 5) export state (so other machine can apply it)
  export_linux_state
}

function mac_flow() {
  # 1) pull dotfiles state
  git_pull_dotfiles

  # 2) sync local machine to dotfiles
  brew_bundle_sync_mac

  # 3) upgrade brew + common tools
  upgrade_brew

  # 4) export state
  export_mac_state
}

# ----------------------------
# Execute
# ----------------------------
ensure_dotfiles_dir

# Common upgrades (cross-platform)
common_flow

# OS-specific steps
if [[ "$OSTYPE" == "darwin"* ]]; then
  mac_flow
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  linux_flow
else
  echo "Unsupported operating system: $OSTYPE"
  exit 1
fi


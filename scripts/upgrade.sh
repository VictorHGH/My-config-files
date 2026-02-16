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

function normalize_brewfile_in_place() {
  local file="$1"
  local raw_tmp tap_tmp brew_tmp cask_tmp mas_tmp vscode_tmp whalebrew_tmp rest_tmp out_tmp

  raw_tmp="$(mktemp)"
  tap_tmp="$(mktemp)"
  brew_tmp="$(mktemp)"
  cask_tmp="$(mktemp)"
  mas_tmp="$(mktemp)"
  vscode_tmp="$(mktemp)"
  whalebrew_tmp="$(mktemp)"
  rest_tmp="$(mktemp)"
  out_tmp="$(mktemp)"

  grep -vE '^\s*#|^\s*$' "$file" > "$raw_tmp"

  grep -E '^tap[[:space:]]' "$raw_tmp" | LC_ALL=C sort -u > "$tap_tmp" || true
  grep -E '^brew[[:space:]]' "$raw_tmp" | LC_ALL=C sort -u > "$brew_tmp" || true
  grep -E '^cask[[:space:]]' "$raw_tmp" | LC_ALL=C sort -u > "$cask_tmp" || true
  grep -E '^mas[[:space:]]' "$raw_tmp" | LC_ALL=C sort -u > "$mas_tmp" || true
  grep -E '^vscode[[:space:]]' "$raw_tmp" | LC_ALL=C sort -u > "$vscode_tmp" || true
  grep -E '^whalebrew[[:space:]]' "$raw_tmp" | LC_ALL=C sort -u > "$whalebrew_tmp" || true
  grep -vE '^(tap|brew|cask|mas|vscode|whalebrew)[[:space:]]' "$raw_tmp" | LC_ALL=C sort -u > "$rest_tmp" || true

  cat "$tap_tmp" "$brew_tmp" "$cask_tmp" "$mas_tmp" "$vscode_tmp" "$whalebrew_tmp" "$rest_tmp" > "$out_tmp"
  mv "$out_tmp" "$file"

  rm -f "$raw_tmp" "$tap_tmp" "$brew_tmp" "$cask_tmp" "$mas_tmp" "$vscode_tmp" "$whalebrew_tmp" "$rest_tmp"
}

function is_git_repo() {
  [[ -d "$DOTFILES_DIR/.git" ]]
}

function ensure_dotfiles_dir() {
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
  fi
}

# ----------------------------
# Dotfiles: safe git pull
# ----------------------------
function git_pull_dotfiles() {
  if [[ "$NO_GIT_PULL" -eq 1 ]]; then
    print_help "git pull (skipped)"
    return
  fi

  print_help "git pull (dotfiles)"

  if ! is_git_repo; then
    echo "Not a git repo: $DOTFILES_DIR (skipping)"
    return
  fi

  # Auto-stash if there are local changes (tracked, staged, or untracked)
  run "cd '$DOTFILES_DIR' && \
    had_changes=0; \
    if [[ -n \"\$(git status --porcelain)\" ]]; then \
      had_changes=1; \
      echo 'Local changes detected: stashing before pull...'; \
      git stash push -u -m 'auto-stash by sync script'; \
    fi; \
    git pull --rebase; \
    if [[ \$had_changes -eq 1 ]]; then \
      echo 'Restoring stashed changes...'; \
      git stash pop || true; \
    fi"
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
    run "npm -g update || true"
  else
    echo "npm not found (skipping)"
  fi
}

function upgrade_nvim() {
  print_help "Neovim (Lazy.nvim)"

  if ! have nvim; then
    echo "nvim not found (skipping)"
    return
  fi

  # If you have a custom :UpgradeNvim command, use it; otherwise run Lazy sync.
  # exists(':Cmd') returns 2 for user-defined commands, 1 for built-in, 0 if missing.
  local has_custom
  has_custom="$(
    nvim --headless \
      +"silent! lua print(vim.fn.exists(':UpgradeNvim'))" \
      +qa 2>/dev/null | tail -n 1 || true
  )"

  if [[ "$has_custom" == "2" || "$has_custom" == "1" ]]; then
    run "nvim --headless '+silent! UpgradeNvim' '+qa' || true"
  else
    run "nvim --headless '+silent! Lazy! sync' '+qa' || true"
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

  local desired_tmp found_tmp missing_tmp
  desired_tmp="$(mktemp)"
  found_tmp="$(mktemp)"
  missing_tmp="$(mktemp)"

  # desired list
  grep -vE '^\s*#|^\s*$' "$PACMAN_LIST" | sort -u > "$desired_tmp"

  # split into found vs missing (in enabled repos)
  while read -r pkg; do
    [[ -z "$pkg" ]] && continue
    if pacman -Si "$pkg" >/dev/null 2>&1; then
      echo "$pkg" >> "$found_tmp"
    else
      echo "$pkg" >> "$missing_tmp"
    fi
  done < "$desired_tmp"

  if [[ -s "$missing_tmp" ]]; then
    echo
    echo "WARNING: These packages were not found in enabled repos (skipping them):"
    cat "$missing_tmp"
    echo
  fi

  if [[ -s "$found_tmp" ]]; then
    run "sudo pacman -S --needed - < '$found_tmp'"
  else
    echo "No installable packages found (after filtering)."
  fi

  rm -f "$desired_tmp" "$found_tmp" "$missing_tmp"
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

  local desired_tmp current_tmp extras_tmp protect_tmp
  desired_tmp="$(mktemp)"
  current_tmp="$(mktemp)"
  extras_tmp="$(mktemp)"
  protect_tmp="$(mktemp)"

  grep -vE '^\s*#|^\s*$' "$PACMAN_LIST" | sort -u > "$desired_tmp"
  pacman -Qqe | sort -u > "$current_tmp"

  comm -23 "$current_tmp" "$desired_tmp" > "$extras_tmp"

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
  run "mkdir -p '$DOTFILES_DIR/resources/pacman'"
  run "sudo pacman -Qqe | LC_ALL=C sort -u > '$PACMAN_LIST'"

  if have brew; then
    run "mkdir -p '$DOTFILES_DIR/resources/homebrew'"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "+ brew bundle dump --file '<tmp>' --force && normalize_brewfile_in_place '<tmp>' && mv '<tmp>' '$BREWFILE_LINUX'"
    else
      local brew_tmp
      brew_tmp="$(mktemp)"
      brew bundle dump --file "$brew_tmp" --force
      normalize_brewfile_in_place "$brew_tmp"
      mv "$brew_tmp" "$BREWFILE_LINUX"
    fi
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
  git_pull_dotfiles
  pacman_sync_install_missing
  pacman_strict_remove_extras
  pacman_upgrade
  brew_bundle_sync_linux
  upgrade_brew
  export_linux_state
}

function mac_flow() {
  git_pull_dotfiles
  brew_bundle_sync_mac
  upgrade_brew
  export_mac_state
}

# ----------------------------
# Execute
# ----------------------------
ensure_dotfiles_dir

# Cross-platform upgrades first (including Neovim plugins)
common_flow

if [[ "$OSTYPE" == "darwin"* ]]; then
  mac_flow
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  linux_flow
else
  echo "Unsupported operating system: $OSTYPE"
  exit 1
fi

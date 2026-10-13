#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PACMAN_FILE="$DOTFILES_DIR/resources/pacman/packages.txt"
AUR_FILE="$DOTFILES_DIR/resources/aur/packages.txt"
PACMAN_EXCLUDE="$DOTFILES_DIR/resources/pacman/exclude.txt"
AUR_EXCLUDE="$DOTFILES_DIR/resources/aur/exclude.txt"
OMZ_COMMIT_FILE="$DOTFILES_DIR/resources/oh-my-zsh/commit"
failures=0

pass() {
  printf '[audit] ok: %s\n' "$*"
}

fail() {
  printf '[audit] error: %s\n' "$*" >&2
  failures=1
}

check_syntax() {
  bash -n "$DOTFILES_DIR/scripts/bootstrap.sh" || fail "bootstrap.sh syntax"
  bash -n "$DOTFILES_DIR/scripts/ensure-early-kbd.sh" || fail "ensure-early-kbd.sh syntax"
  zsh -n "$DOTFILES_DIR/scripts/upgrade.sh" || fail "upgrade.sh syntax"
  zsh -n "$DOTFILES_DIR/global/.zshrc" || fail ".zshrc syntax"
  [[ "$failures" -eq 0 ]] && pass "shell syntax"
}

check_git_diff() {
  git -C "$DOTFILES_DIR" diff --check || fail "whitespace errors in diff"
  [[ "$failures" -eq 0 ]] && pass "git diff format"
}

check_manifests() {
  local pkg

  if ! command -v pacman >/dev/null 2>&1; then
    printf '[audit] skip: pacman is not available\n'
    return
  fi

  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    pacman -Si "$pkg" >/dev/null 2>&1 || fail "$pkg is missing from enabled pacman repositories"
  done < "$PACMAN_FILE"

  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    if pacman -Si "$pkg" >/dev/null 2>&1; then
      fail "$pkg is in an official repository; move it to $PACMAN_FILE"
    fi
  done < "$AUR_FILE"

  [[ "$failures" -eq 0 ]] && pass "Pacman and AUR manifests"
}

check_exclusions() {
  local list exclude_file pkg

  for list in "$PACMAN_FILE" "$AUR_FILE"; do
    if [[ "$list" == "$PACMAN_FILE" ]]; then
      exclude_file="$PACMAN_EXCLUDE"
    else
      exclude_file="$AUR_EXCLUDE"
    fi

    while IFS= read -r pkg; do
      [[ -z "$pkg" || "$pkg" == \#* ]] && continue
      if grep -Fxq "$pkg" "$list"; then
        fail "$pkg is excluded but still present in $list"
      fi
    done < "$exclude_file"
  done

  [[ "$failures" -eq 0 ]] && pass "manifest exclusions"
}

check_oh_my_zsh() {
  local pinned installed

  [[ -s "$OMZ_COMMIT_FILE" ]] || {
    fail "missing Oh My Zsh commit file"
    return
  }

  pinned="$(<"$OMZ_COMMIT_FILE")"
  [[ "$pinned" =~ ^[0-9a-f]{40}$ ]] || {
    fail "invalid Oh My Zsh commit"
    return
  }

  if [[ -d "$HOME/.oh-my-zsh/.git" ]]; then
    installed="$(git -C "$HOME/.oh-my-zsh" rev-parse HEAD)"
    [[ "$installed" == "$pinned" ]] || fail "installed Oh My Zsh differs from the pinned commit"
  fi

  [[ "$failures" -eq 0 ]] && pass "Oh My Zsh commit"
}

check_i3_stow() {
  local tmpdir

  if ! command -v stow >/dev/null 2>&1 || ! command -v i3 >/dev/null 2>&1; then
    printf '[audit] skip: stow or i3 is not available\n'
    return
  fi

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT
  stow -d "$DOTFILES_DIR" -t "$tmpdir" arch
  HOME="$tmpdir" i3 -C -c "$tmpdir/.config/i3/config" || fail "i3 config validation"
  rm -rf "$tmpdir"
  trap - EXIT

  [[ "$failures" -eq 0 ]] && pass "i3 configuration with Stow"
}

check_syntax
check_git_diff
check_manifests
check_exclusions
check_oh_my_zsh
check_i3_stow

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

printf '[audit] complete\n'

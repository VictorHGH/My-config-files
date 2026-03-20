#!/usr/bin/env bash
set -euo pipefail

MKINITCPIO_CONF="${MKINITCPIO_CONF:-/etc/mkinitcpio.conf}"
REQUIRED_MODULES=(usbhid hid_generic xhci_hcd xhci_pci ehci_pci)

FORCE_REBUILD=0
SKIP_REBUILD=0

usage() {
  cat <<'EOF'
Usage: ensure-early-kbd.sh [--rebuild] [--no-rebuild]

Options:
  --rebuild      Force mkinitcpio -P even if MODULES already contains required entries
  --no-rebuild   Skip mkinitcpio -P
  -h, --help     Show this help

Environment:
  MKINITCPIO_CONF   Path to mkinitcpio.conf (default: /etc/mkinitcpio.conf)
EOF
}

log() {
  printf '[ensure-early-kbd] %s\n' "$*"
}

warn() {
  printf '[ensure-early-kbd][warn] %s\n' "$*" >&2
}

die() {
  printf '[ensure-early-kbd][error] %s\n' "$*" >&2
  exit 1
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --rebuild)
        FORCE_REBUILD=1
        shift
        ;;
      --no-rebuild)
        SKIP_REBUILD=1
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

extract_modules_line() {
  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == MODULES=\(* ]]; then
      printf '%s\n' "$line"
      return 0
    fi
  done < "$MKINITCPIO_CONF"

  return 1
}

ensure_required_modules() {
  local modules_line modules_content required module found
  local modules=()
  local changed=0

  if ! modules_line="$(extract_modules_line)"; then
    die "Could not find MODULES=(...) in $MKINITCPIO_CONF"
  fi

  modules_content="${modules_line#MODULES=(}"
  modules_content="${modules_content%%)*}"

  if [[ -n "$modules_content" ]]; then
    read -r -a modules <<< "$modules_content"
  fi

  for required in "${REQUIRED_MODULES[@]}"; do
    found=0
    for module in "${modules[@]}"; do
      if [[ "$module" == "$required" ]]; then
        found=1
        break
      fi
    done

    if [[ "$found" -eq 0 ]]; then
      modules+=("$required")
      changed=1
    fi
  done

  if [[ "$changed" -eq 0 ]]; then
    log "Required modules already present in $MKINITCPIO_CONF"
    return 1
  fi

  local new_line="MODULES=(${modules[*]})"
  local tmp_file
  local replaced=0

  tmp_file="$(mktemp)"
  trap 'rm -f "$tmp_file"' EXIT

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$replaced" -eq 0 && "$line" == MODULES=\(* ]]; then
      printf '%s\n' "$new_line" >> "$tmp_file"
      replaced=1
    else
      printf '%s\n' "$line" >> "$tmp_file"
    fi
  done < "$MKINITCPIO_CONF"

  if [[ "$replaced" -eq 0 ]]; then
    die "Failed to rewrite MODULES line in $MKINITCPIO_CONF"
  fi

  mv "$tmp_file" "$MKINITCPIO_CONF"
  trap - EXIT

  log "Updated MODULES line in $MKINITCPIO_CONF"
  return 0
}

rebuild_initramfs_if_needed() {
  local config_changed="$1"

  if [[ "$SKIP_REBUILD" -eq 1 ]]; then
    log "Skipping mkinitcpio rebuild (--no-rebuild)"
    return
  fi

  if [[ "$FORCE_REBUILD" -eq 1 || "$config_changed" -eq 1 ]]; then
    if ! command -v mkinitcpio >/dev/null 2>&1; then
      warn "mkinitcpio not found; skipping rebuild"
      return
    fi

    log "Running mkinitcpio -P"
    mkinitcpio -P
  else
    log "No rebuild needed"
  fi
}

main() {
  parse_args "$@"

  [[ -f "$MKINITCPIO_CONF" ]] || die "Config file not found: $MKINITCPIO_CONF"

  if ensure_required_modules; then
    rebuild_initramfs_if_needed 1
  else
    rebuild_initramfs_if_needed 0
  fi
}

main "$@"

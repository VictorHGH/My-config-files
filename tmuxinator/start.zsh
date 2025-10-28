#!/usr/bin/env zsh
set -e
set -u
set -o pipefail

folderpath="$PWD"
tmuxinator_src="$HOME/dotfiles/tmuxinator"
tmuxinator_dst="$folderpath/tmuxinator"

# 1) chequeos básicos
[[ -d "$tmuxinator_src" ]] || { print -r -- "No existe $tmuxinator_src"; exit 1; }

# evitar copiar si el destino ES el origen
if [[ "$(realpath "$tmuxinator_src")" == "$(realpath "$tmuxinator_dst" 2>/dev/null || echo '')" ]]; then
  print -r -- "Destino = origen; no copio. (¿Estás ejecutando dentro de dotfiles?)"
  exit 0
fi

# 2) asegurar .gitignore
touch "$folderpath/.gitignore"
grep -qxF "tmuxinator/start.*" "$folderpath/.gitignore" || echo "tmuxinator/start.*" >> "$folderpath/.gitignore"

# 3) copiar carpeta tmuxinator (excluyendo lo que luego será symlink)
mkdir -p "$tmuxinator_dst"
if command -v rsync >/dev/null 2>&1; then
  rsync -a \
    --exclude 'start.zsh' \
    --exclude 'start.zsh' \
    --exclude 'move_windows.zsh' \
    --exclude 'move_windows.zsh' \
    "$tmuxinator_src/" "$tmuxinator_dst/"
else
  # fallback simple
  cp -r "$tmuxinator_src"/* "$tmuxinator_dst/"
  rm -f "$tmuxinator_dst/start.zsh" "$tmuxinator_dst/start.zsh" \
        "$tmuxinator_dst/move_windows.zsh" "$tmuxinator_dst/move_windows.zsh" 2>/dev/null || true
fi
print -r -- "✓ Copiado tmuxinator → $tmuxinator_dst"

# 4) limpiar restos legacy si quedaron
rm -f "$tmuxinator_dst/start.zsh" 2>/dev/null || true

# 5) crear symlink a move_windows.zsh del repo (forzar/actualizar)
if [[ -f "$tmuxinator_src/move_windows.zsh" ]]; then
  ln -sfn "$tmuxinator_src/move_windows.zsh" "$tmuxinator_dst/move_windows.zsh"
  print -r -- "✓ Symlink: $tmuxinator_dst/move_windows.zsh → $tmuxinator_src/move_windows.zsh"
else
  print -r -- "⚠ No encontré $tmuxinator_src/move_windows.zsh; omito symlink."
fi

print -r -- "Listo."

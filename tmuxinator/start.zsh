#!/usr/bin/env zsh
set -e
set -u
set -o pipefail

folderpath="$PWD"
tmuxinator_src="$HOME/dotfiles/tmuxinator"
tmuxinator_dst="$folderpath/tmuxinator"

# banderitas para saber qué hicimos
created_dir=0
created_symlink=0
created_vars=0
copied_template=0
created_global_link=0

cleanup() {
  echo
  echo "⚠ Interrumpido. Limpiando..."
  if (( copied_template == 1 )); then
    rm -f "$dest_template" 2>/dev/null || true
  fi
  if (( created_symlink == 1 )); then
    rm -f "$tmuxinator_dst/move_windows.zsh" 2>/dev/null || true
  fi
  if (( created_vars == 1 )); then
    rm -f "$tmuxinator_dst/variables.zsh" 2>/dev/null || true
  fi
  if (( created_global_link == 1 )); then
    rm -f "$HOME/.config/tmuxinator/${newname:-}" 2>/dev/null || true
  fi
  if (( created_dir == 1 )); then
    rmdir "$tmuxinator_dst" 2>/dev/null || true
  fi
  echo "🧹 Limpieza completa. Cancelado por el usuario."
  exit 130
}

trap cleanup INT

# 1) Chequeos básicos
[[ -d "$tmuxinator_src" ]] || { print -r -- "No existe $tmuxinator_src"; exit 1; }

if [[ "$(realpath "$tmuxinator_src")" == "$(realpath "$tmuxinator_dst" 2>/dev/null || echo '')" ]]; then
  print -r -- "Destino = origen; no copio. (¿Estás ejecutando dentro de dotfiles?)"
  exit 0
fi

# 2) Asegurar .gitignore
touch "$folderpath/.gitignore"
for rule in "tmuxinator/start.*" "tmuxinator/move_windows.zsh"; do
  grep -qxF "$rule" "$folderpath/.gitignore" || echo "$rule" >> "$folderpath/.gitignore"
done

# 3) Crear carpeta destino
if [[ ! -d "$tmuxinator_dst" ]]; then
  mkdir -p "$tmuxinator_dst"
  created_dir=1
fi

# 4) Copiar base
if command -v rsync >/dev/null 2>&1; then
  rsync -a \
    --exclude 'start.zsh' \
    --exclude 'move_windows.zsh' \
    --exclude 'variables.zsh' \
    --exclude 'template.yml' \
    "$tmuxinator_src/" "$tmuxinator_dst/"
else
  cp -r "$tmuxinator_src"/* "$tmuxinator_dst/" 2>/dev/null || true
  rm -f "$tmuxinator_dst/start.zsh" "$tmuxinator_dst/move_windows.zsh" \
        "$tmuxinator_dst/variables.zsh" "$tmuxinator_dst/template.yml" 2>/dev/null || true
fi
print -r -- "✓ Copiado base → $tmuxinator_dst"

# 5) Symlink move_windows.zsh
if [[ -f "$tmuxinator_src/move_windows.zsh" ]]; then
  ln -sfn "$tmuxinator_src/move_windows.zsh" "$tmuxinator_dst/move_windows.zsh"
  created_symlink=1
  print -r -- "✓ Symlink: move_windows.zsh → $tmuxinator_src/move_windows.zsh"
else
  print -r -- "⚠ No encontré move_windows.zsh en dotfiles; omito symlink."
fi

# 6) variables.zsh
if [[ -f "$tmuxinator_src/variables.zsh" ]]; then
  dest_vars="$tmuxinator_dst/variables.zsh"
  if [[ -e "$dest_vars" ]]; then
    print -n "‘variables.zsh’ ya existe. ¿Sobrescribir? [y/N]: "
    read -r ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      cp -f "$tmuxinator_src/variables.zsh" "$dest_vars"
      created_vars=1
    fi
  else
    cp -f "$tmuxinator_src/variables.zsh" "$dest_vars"
    created_vars=1
  fi
else
  print -r -- "⚠ No se encontró variables.zsh."
fi

# 7) Copiar y personalizar template.yml
src_template="$tmuxinator_src/template.yml"
if [[ -f "$src_template" ]]; then
  print ""
  print "=== Nombre del YAML de este proyecto ==="
  default_yml="${folderpath:t}.yml"
  print -n "Nombre del archivo .yml [${default_yml}]: "
  read -r newname
  [[ -z "$newname" ]] && newname="$default_yml"
  [[ "$newname" != *.yml ]] && newname="${newname}.yml"

  dest_template="$tmuxinator_dst/$newname"
  cp -f "$src_template" "$dest_template"
  copied_template=1

  print -n "Nombre interno del proyecto (campo 'name:' en el yml) [${folderpath:t}]: "
  read -r internal_name
  [[ -z "$internal_name" ]] && internal_name="${folderpath:t}"

  tmpfile="${dest_template}.tmp"
  sed -E \
    -e "s|^name: .*|name: ${internal_name}|" \
    -e "s|^root: .*|root: ${folderpath}|" \
    "$dest_template" > "$tmpfile"
  mv "$tmpfile" "$dest_template"
  print -r -- "✓ Actualizado name: ${internal_name}"
  print -r -- "✓ Actualizado root: ${folderpath}"
else
  print -r -- "⚠ No encontré $src_template."
fi

# 8) Crear symlink del YAML global
if [[ -n "${dest_template:-}" && -f "$dest_template" ]]; then
  mkdir -p "$HOME/.config/tmuxinator"
  ln -sfn "$dest_template" "$HOME/.config/tmuxinator/${newname}"
  created_global_link=1
  print -r -- "✓ Symlink creado: ~/.config/tmuxinator/${newname}"
fi

# desactivar cleanup si todo fue bien
trap - INT

print ""
print "✅ Listo. Estructura esperada ahora:"
print "tmuxinator/"
print "├── ${newname:-<tu-nombre>.yml}"
print "├── move_windows.zsh"
print "└── variables.zsh"


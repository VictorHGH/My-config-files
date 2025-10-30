#!/usr/bin/env zsh
set -e
set -u
set -o pipefail

folderpath="$PWD"
tmuxinator_src="$HOME/dotfiles/tmuxinator"
tmuxinator_dst="$folderpath/tmuxinator"

# 1) Chequeos básicos
[[ -d "$tmuxinator_src" ]] || { print -r -- "No existe $tmuxinator_src"; exit 1; }

# Evitar copiar en el propio dotfiles
if [[ "$(realpath "$tmuxinator_src")" == "$(realpath "$tmuxinator_dst" 2>/dev/null || echo '')" ]]; then
  print -r -- "Destino = origen; no copio. (¿Estás ejecutando dentro de dotfiles?)"
  exit 0
fi

# 2) Asegurar .gitignore y reglas de tmuxinator
touch "$folderpath/.gitignore"
for rule in "tmuxinator/start.*" "tmuxinator/move_windows.zsh"; do
  grep -qxF "$rule" "$folderpath/.gitignore" || echo "$rule" >> "$folderpath/.gitignore"
done

# 3) Crear carpeta destino
mkdir -p "$tmuxinator_dst"

# 4) Copiar base EXCLUYENDO los archivos gestionados aparte
if command -v rsync >/dev/null 2>&1; then
  rsync -a \
    --exclude 'start.zsh' \
    --exclude 'move_windows.zsh' \
    --exclude 'variables.zsh' \
    --exclude 'template.yml' \
    "$tmuxinator_src/" "$tmuxinator_dst/"
else
  cp -r "$tmuxinator_src"/* "$tmuxinator_dst/" 2>/dev/null || true
  rm -f \
    "$tmuxinator_dst/start.zsh" \
    "$tmuxinator_dst/move_windows.zsh" \
    "$tmuxinator_dst/variables.zsh" \
    "$tmuxinator_dst/template.yml" 2>/dev/null || true
fi
print -r -- "✓ Copiado base → $tmuxinator_dst"

# 5) Symlink para move_windows.zsh (compartido)
if [[ -f "$tmuxinator_src/move_windows.zsh" ]]; then
  ln -sfn "$tmuxinator_src/move_windows.zsh" "$tmuxinator_dst/move_windows.zsh"
  print -r -- "✓ Symlink: move_windows.zsh → $tmuxinator_src/move_windows.zsh"
else
  print -r -- "⚠ No encontré move_windows.zsh en dotfiles; omito symlink."
fi

# 6) variables.zsh es PER-PROYECTO → copiar (no symlink)
if [[ -f "$tmuxinator_src/variables.zsh" ]]; then
  dest_vars="$tmuxinator_dst/variables.zsh"
  if [[ -e "$dest_vars" ]]; then
    print -n "‘variables.zsh’ ya existe en el proyecto. ¿Sobrescribir con el de dotfiles? [y/N]: "
    read -r ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      cp -f "$tmuxinator_src/variables.zsh" "$dest_vars"
      print -r -- "✓ variables.zsh actualizado (copia local del proyecto)"
    else
      print -r -- "↷ Conservo variables.zsh existente"
    fi
  else
    cp -f "$tmuxinator_src/variables.zsh" "$dest_vars"
    print -r -- "✓ variables.zsh copiado (local del proyecto)"
  fi
else
  print -r -- "⚠ No se encontró variables.zsh en dotfiles; crea tu variables.zsh local."
fi

# 7) Copiar el template único con nombre .yml personalizado
src_template="$tmuxinator_src/template.yml"
if [[ -f "$src_template" ]]; then
  print ""
  print "=== Nombre del YAML de este proyecto ==="
  # nombre de archivo por defecto = nombre de la carpeta
  default_yml="${folderpath:t}.yml"
  print -n "Nombre del archivo .yml [${default_yml}]: "
  read -r newname
  [[ -z "$newname" ]] && newname="$default_yml"
  [[ "$newname" != *.yml ]] && newname="${newname}.yml"

  dest_template="$tmuxinator_dst/$newname"
  if [[ -e "$dest_template" ]]; then
    print -n "‘$newname’ ya existe. ¿Sobrescribir? [y/N]: "
    read -r ok
    if [[ ! "$ok" =~ ^[Yy]$ ]]; then
      print "Cancelado."
      print -r -- "ℹ Puedes renombrarlo manualmente en: $tmuxinator_dst"
      exit 0
    fi
  fi

  # copiar el template
  cp -f "$src_template" "$dest_template"
  print -r -- "✓ Copiado: $dest_template"

  # 7.1 preguntar por el "name:" que va dentro del YAML
  print -n "Nombre interno del proyecto (campo 'name:' en el yml) [${folderpath:t}]: "
  read -r internal_name
  [[ -z "$internal_name" ]] && internal_name="${folderpath:t}"

  # 7.2 sustituir name: y root:
  # usamos editores portables (zsh + sed)
  # sustituye la línea que empieza con "name:" y con "root:"
  # si quieres evitar que falle si no está, usamos sed -E
  tmpfile="${dest_template}.tmp"
  # nota: usamos '|' como delimitador para no pelear con '/'
  sed -E \
    -e "s|^name: .*|name: ${internal_name}|" \
    -e "s|^root: .*|root: ${folderpath}|" \
    "$dest_template" > "$tmpfile"
  mv "$tmpfile" "$dest_template"
  print -r -- "✓ Actualizado name: ${internal_name}"
  print -r -- "✓ Actualizado root: ${folderpath}"
else
  print -r -- "⚠ No encontré $src_template. Omite copia de template."
fi

# 8) Crear symlink del YAML en ~/.config/tmuxinator/
if [[ -n "${dest_template:-}" && -f "$dest_template" ]]; then
  mkdir -p "$HOME/.config/tmuxinator"
  ln -sfn "$dest_template" "$HOME/.config/tmuxinator/${newname}"
  print -r -- "✓ Symlink creado: ~/.config/tmuxinator/${newname} → $dest_template"
  print -r -- "→ Puedes iniciar con: tmuxinator start ${newname:r}"
fi

print ""
print "✅ Listo. Estructura esperada ahora:"
print "tmuxinator/"
print "├── ${newname:-<tu-nombre>.yml}"
print "├── move_windows.zsh -> $tmuxinator_src/move_windows.zsh"
print "└── variables.zsh"


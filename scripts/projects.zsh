#!/usr/bin/env zsh
# tmx: launcher + delete/edit/clean para tmuxinator con manejo de symlinks rotos
set -euo pipefail

command -v tmuxinator >/dev/null 2>&1 || { print "tmuxinator no está instalado."; exit 1; }
command -v fzf >/dev/null 2>&1 || { print "fzf no está instalado."; exit 1; }

# -------------------------
# Opcional: limpieza masiva
# -------------------------
if [[ "${1:-}" == "--clean-broken" ]]; then
  integer count=0
  for dir in "$HOME/.config/tmuxinator" "$HOME/.tmuxinator"; do
    [[ -d $dir ]] || continue
    for y in "$dir"/*.yml(N@); do
      [[ -h "$y" ]] || continue
      target="$(readlink -f "$y" 2>/dev/null || realpath "$y" 2>/dev/null || true)"
      if [[ -z "$target" || ! -f "$target" ]]; then
        unlink "$y" && print "✓ Eliminado symlink roto: $y" && ((count++))
      fi
    done
  done
  ((count==0)) && print "No se encontraron symlinks rotos."
  exit 0
fi

# -------------------------
# Recolectar nombres/rutas
# -------------------------
typeset -A PATHS   # nombre -> ruta (archivo en config; puede ser symlink)
typeset -A KIND    # nombre -> file | symlink | missing
typeset -A TARGET  # nombre -> ruta real (si symlink resuelve)
typeset -a CHOICES

# Prioriza ~/.config/tmuxinator sobre ~/.tmuxinator
for dir in "$HOME/.config/tmuxinator" "$HOME/.tmuxinator"; do
  [[ -d $dir ]] || continue
  for y in "$dir"/*.yml(N@); do
    name="${y:t:r}"
    [[ -z "${PATHS[$name]-}" ]] || continue
    PATHS[$name]="$y"
    if [[ -h "$y" ]]; then
      KIND[$name]="symlink"
      if target="$(readlink -f "$y" 2>/dev/null || realpath "$y" 2>/dev/null || true)"; then
        [[ -n "$target" && -f "$target" ]] && TARGET[$name]="$target" || TARGET[$name]=""
      else
        TARGET[$name]=""
      fi
    elif [[ -f "$y" ]]; then
      KIND[$name]="file"
      TARGET[$name]="$y"
    else
      KIND[$name]="missing"
      TARGET[$name]=""
    fi
  done
done

# Fallback: parsear `tmuxinator list` si no encontró nada
if (( ${#PATHS} == 0 )); then
  for name in ${(f)"$(tmuxinator list | sed '1d' | tr -s '[:space:]' '\n' | sed '/^$/d')"}; do
    for p in "$HOME/.config/tmuxinator/$name.yml" "$HOME/.tmuxinator/$name.yml"; do
      if [[ -e "$p" ]]; then
        PATHS[$name]="$p"
        if [[ -h "$p" ]]; then
          KIND[$name]="symlink"
          if target="$(readlink -f "$p" 2>/dev/null || realpath "$p" 2>/dev/null || true)"; then
            [[ -n "$target" && -f "$target" ]] && TARGET[$name]="$target" || TARGET[$name]=""
          else
            TARGET[$name]=""
          fi
        elif [[ -f "$p" ]]; then
          KIND[$name]="file"
          TARGET[$name]="$p"
        else
          KIND[$name]="missing"
          TARGET[$name]=""
        fi
        break
      fi
    done
    [[ -n "${PATHS[$name]-}" ]] || { PATHS[$name]="/dev/null"; KIND[$name]="missing"; TARGET[$name]=""; }
  done
fi

# Construir líneas con TABS REALES: name \t path \t kind \t target
for k in ${(ok)PATHS}; do
  CHOICES+=("$(printf '%s\t%s\t%s\t%s' "$k" "${PATHS[$k]}" "${KIND[$k]:-missing}" "${TARGET[$k]:-}")")
done
(( ${#CHOICES} > 0 )) || { print "No hay proyectos de tmuxinator."; exit 0; }

# -------------------------
# Helpers
# -------------------------
trash_or_rm() {
  local f="$1"
  if [[ -h "$f" ]]; then unlink "$f" && return 0; fi
  if command -v gio       >/dev/null 2>&1; then gio trash "$f" && return 0; fi
  if command -v trash-put >/dev/null 2>&1; then trash-put "$f" && return 0; fi
  if command -v trash     >/dev/null 2>&1; then trash "$f" && return 0; fi
  if [[ "$OSTYPE" == darwin* ]]; then mv -f "$f" "$HOME/.Trash/$(basename "$f")" && return 0; fi
  rm -i "$f"
}

open_in_editor() {
  local file="$1"
  local editor="${EDITOR:-}"
  [[ -z "$editor" ]] && command -v nvim >/dev/null && editor="nvim"
  [[ -z "$editor" ]] && command -v vim  >/dev/null && editor="vim"
  [[ -z "$editor" ]] && command -v code >/dev/null && editor="code -w"
  [[ -z "$editor" ]] && editor="vi"
  eval "$editor \"\$file\""
}

# -------------------------
# UI (fzf)
# -------------------------
local header=$'Enter: iniciar  |  Ctrl-D: borrar  |  Ctrl-O: abrir  |  Ctrl-R: refrescar  |  --clean-broken: limpiar symlinks rotos'

out="$(
  printf '%s\n' "${CHOICES[@]}" | \
  fzf --prompt='tmuxinator> ' \
      --layout=reverse \
      --header="$header" \
      --with-nth=1 \
      --delimiter=$'\t' \
      --expect=ctrl-d,ctrl-o,ctrl-r \
      --preview '
        name={1}; path={2}; kind={3}; target={4};
        if [ "$kind" = symlink ]; then
          if [ -n "$target" ] && [ -f "$target" ]; then
            echo "SYMLINK → $target"
            sed -n "1,120p" "$target" 2>/dev/null
          else
            echo "SYMLINK ROTO: $path"
          fi
        elif [ -f "$path" ]; then
          sed -n "1,120p" "$path" 2>/dev/null
        else
          echo "(archivo no encontrado)"
        fi
      ' \
      --preview-window=down:30%:wrap,border
)" || exit 0

key="$(printf '%s\n' "$out" | head -n1)"
line="$(printf '%s\n' "$out" | tail -n +2)"
[[ -n "${line:-}" ]] || exit 0

# Parseo por TAB
typeset -a fields
IFS=$'\t' read -rA fields <<< "$line"
sel_name="${fields[1]}"
sel_path="${fields[2]}"
sel_kind="${fields[3]}"
sel_target="${fields[4]}"

# Ctrl-R: refrescar
if [[ "$key" == "ctrl-r" ]]; then
  exec "$0"
fi

# Ctrl-O: abrir YAML en editor
if [[ "$key" == "ctrl-o" ]]; then
  target_to_open=""
  if [[ -n "${sel_target:-}" && -f "$sel_target" ]]; then
    target_to_open="$sel_target"
  elif [[ -f "$sel_path" ]]; then
    target_to_open="$sel_path"
  fi
  if [[ -z "$target_to_open" ]]; then
    print "No hay YAML para abrir (quizá symlink roto)."
    exit 0
  fi
  open_in_editor "$target_to_open"
  exit 0
fi

# Ctrl-D: borrar (symlink → unlink; file → papelera)
if [[ "$key" == "ctrl-d" ]]; then
  print -n "¿Borrar '${sel_name}'? (eliminará YAML en ~/.config y ~/.tmuxinator si existen) [y/N]: "
  read -r ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    typeset -a candidates
    candidates=("$HOME/.config/tmuxinator/${sel_name}.yml" "$HOME/.tmuxinator/${sel_name}.yml")
    integer any=0
    for f in "${candidates[@]}"; do
      if [[ -e "$f" || -h "$f" ]]; then
        trash_or_rm "$f"
        print "✓ Borrado: $f"
        any=1
      fi
    done
    (( any == 0 )) && print "Nada que borrar (no se encontraron archivos)."
  else
    print "Cancelado."
  fi
  exit 0
fi

# Enter: si es symlink roto, ofrecer limpiarlo
if [[ "$sel_kind" == "symlink" && ( -z "${sel_target:-}" || ! -f "$sel_target" ) ]]; then
  print -n "El symlink está roto: ${sel_path}. ¿Eliminarlo ahora? [y/N]: "
  read -r del
  if [[ "$del" =~ ^[Yy]$ ]]; then
    trash_or_rm "$sel_path"
    print "✓ Eliminado symlink roto: $sel_path"
  else
    print "Abortado."
  fi
  exit 0
fi

# Verificación final antes de iniciar
if [[ ! -f "${sel_path}" && ! -f "${sel_target:-/dev/null}" ]]; then
  print "No se encuentra el YAML para '${sel_name}'. Vuelve a crearlo con tu start.zsh."
  exit 1
fi

# Iniciar por nombre
exec tmuxinator start "$sel_name"


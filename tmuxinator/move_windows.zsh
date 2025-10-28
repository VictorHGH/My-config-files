#!/usr/bin/env zsh

set -euo pipefail

# === Cargar variables (LINKS, link1/link2) ===
SCRIPT_DIR="${0:A:h}"
[[ -f "${SCRIPT_DIR}/variables.sh" ]] && source "${SCRIPT_DIR}/variables.sh"

# Normalizar a array LINKS
typeset -a LINKS_AUX
if typeset -p LINKS >/dev/null 2>&1; then
  LINKS_AUX=("${LINKS[@]}")
else
  [[ -n "${link1:-}" ]] && LINKS_AUX+=("$link1")
  [[ -n "${link2:-}" ]] && LINKS_AUX+=("$link2")
fi

if (( ${#LINKS_AUX} == 0 )); then
  print "No hay LINKS definidos (ni link1/link2). Nada que abrir."
  exit 0
fi

# === Detección simple de monitores por OS (para sugerir default) ===
detect_monitors_linux() {
  if command -v xrandr >/dev/null 2>&1; then
    xrandr --query | awk '/ connected/{c++} END{print (c?c:1)}'
  else
    print 2
  fi
}

detect_monitors_macos() {
  # Aproximación: intenta con 2 como default
  # (Podrías usar `system_profiler SPDisplaysDataType` y parsear, pero es lento)
  print 2
}

# === Prompt monitores ===
ask_monitors() {
  local def
  case "$OSTYPE" in
    linux*)  def="$(detect_monitors_linux)" ;;
    darwin*) def="$(detect_monitors_macos)" ;;
    *)       def="2" ;;
  esac
  print -n "¿Cuántos monitores vas a usar? [${def}]: "
  local ans; IFS= read -r ans
  [[ -z "$ans" ]] && ans="$def"
  # validar entero >=1
  if ! [[ "$ans" =~ '^[0-9]+$' ]] || (( ans < 1 )); then
    print "Valor inválido, usando ${def}"
    ans="$def"
  fi
  print -r -- "$ans"
}

# === Linux ===
open_and_place_linux() {
  local monitors="$1"
  local opener
  if command -v chromium >/dev/null 2>&1; then
    opener=(chromium --new-window)
  elif command -v google-chrome >/dev/null 2>&1; then
    opener=(google-chrome --new-window)
  else
    opener=(xdg-open)
  fi

  for i in {1..${#LINKS_AUX}}; do
    local url="${LINKS_AUX[$i]}"
    "${opener[@]}" "$url" >/dev/null 2>&1 &
    sleep 0.6
    if command -v xdotool >/dev/null 2>&1; then
      # manda cada ventana al "monitor/escritorio" (1..monitors), ciclando
      local target=$(( ((i-1) % monitors) + 1 ))
      # Ajusta a tu WM: super+<N> ya lo usabas
      xdotool key "super+${target}" || true
      sleep 0.2
    fi
  done
}

# === macOS ===
# Abre en Chrome y posiciona cada ventana en una reja horizontal:
# monitor k → {left = k*WIDTH, top = 0, right = (k+1)*WIDTH, bottom = HEIGHT}
open_and_place_macos() {
  local monitors="$1"
  local WIDTH="${MWIDTH:-1920}"
  local HEIGHT="${MHEIGHT:-1080}"

  # Abre todas en Google Chrome (más predecible que mezclar con Safari)
  # Usamos AppleScript para crear ventanas y luego posicionarlas por índice
  # Nota: macOS indexa ventanas desde 1 en orden Z actual; recién creadas suelen ser al frente.
  /usr/bin/osascript <<OSA
on run
  set theLinks to {$(printf "\"%s\"," "${LINKS_AUX[@]}" | sed 's/,$//')}
  tell application "Google Chrome"
    activate
    repeat with i from 1 to (count of theLinks)
      set theURL to item i of theLinks
      if (count of windows) = 0 then
        make new window
      else
        make new window
      end if
      set URL of active tab of window 1 to theURL
      -- mover/resize: monitor destino ciclando 0..(monitors-1)
      set m to ((i - 1) mod ${monitors})
      set leftEdge to m * ${WIDTH}
      set topEdge to 0
      set rightEdge to leftEdge + ${WIDTH}
      set bottomEdge to ${HEIGHT}
      set bounds of window 1 to {leftEdge, topEdge, rightEdge, bottomEdge}
    end repeat
  end tell
end run
OSA
}

# === Main ===
main() {
  local monitors
  monitors="$(ask_monitors)"

  case "$OSTYPE" in
    linux*)  open_and_place_linux "$monitors" ;;
    darwin*) open_and_place_macos "$monitors" ;;
    *)
      print "OS no soportado: $OSTYPE. Abriendo sin posicionar…"
      for url in "${LINKS_AUX[@]}"; do
        if command -v xdg-open >/dev/null 2>&1; then xdg-open "$url" &
        elif command -v open     >/dev/null 2>&1; then open "$url" &
        else print "No encontré cómo abrir '$url'"; fi
        sleep 0.2
      done
      ;;
  esac
}

main "$@"


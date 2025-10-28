#!/usr/bin/env zsh
# ~/.local/bin/tmx
#!/usr/bin/env zsh

set -euo pipefail

typeset -a names
for dir in "$HOME/.config/tmuxinator" "$HOME/.tmuxinator"; do
  [[ -d $dir ]] || continue
  # *.yml(N) hace que no falle si no hay coincidencias
  for y in "$dir"/*.yml(N); do
    names+=("${y:t:r}")   # nombre de archivo sin extensión
  done
done

# si por alguna razón no encontró nada, cae al parser de `tmuxinator list`
if (( ${#names} == 0 )); then
  names=("${(@f)$(tmuxinator list | sed '1d' | tr -s '[:space:]' '\n' | sed '/^$/d')}")
fi

sel="$(printf '%s\n' "${(@u)names[@]}" | sort -u | fzf --prompt='tmuxinator> ')" || exit 0
tmuxinator start "$sel"

#!/usr/bin/env bash
set -euo pipefail

# Genera proyecto.txt con árbol + archivos clave (con redacción de secretos)
# Uso:
#   chmod +x generar_proyecto_txt.sh
#   ./generar_proyecto_txt.sh
# Salida:
#   ./proyecto.txt

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUT_FILE="${ROOT_DIR}/proyecto.txt"

# Carpetas/archivos a excluir del árbol (pesados o locales)
EXCLUDES=(
  ".git"
  "mysql_data"
  "mysql_dev_data"
  "src/vendor"
  "src/node_modules"
  "src/storage"
  "src/bootstrap/cache"
  ".idea"
  ".vscode"
)

# Convierte EXCLUDES en patrón para tree (separado por |)
EXCLUDE_PATTERN="$(IFS="|"; echo "${EXCLUDES[*]}")"

mask_secrets() {
  # Redacta valores en líneas típicas de secretos (sin romper el formato)
  # Ejemplos: MYSQL_PASSWORD=..., APP_KEY=..., SECRET=..., TOKEN=...
  sed -E \
    -e 's/^([A-Za-z0-9_]*PASS(WORD)?[A-Za-z0-9_]*=).*/\1<REDACTED>/I' \
    -e 's/^([A-Za-z0-9_]*SECRET[A-Za-z0-9_]*=).*/\1<REDACTED>/I' \
    -e 's/^([A-Za-z0-9_]*TOKEN[A-Za-z0-9_]*=).*/\1<REDACTED>/I' \
    -e 's/^([A-Za-z0-9_]*APP_KEY=).*/\1<REDACTED>/I'
}

append_file() {
  local rel="$1"
  local abs="${ROOT_DIR}/${rel}"

  if [[ -f "$abs" ]]; then
    {
      echo
      echo "Archivo: ./${rel}"
      echo "----------------------------------------"
      # Evita volcar binarios accidentalmente
      if file -b --mime "$abs" | grep -qi 'charset=binary'; then
        echo "<BINARIO OMITIDO>"
      else
        cat "$abs" | mask_secrets
      fi
      echo
    } >> "$OUT_FILE"
  fi
}

# Lista de archivos “clave” para este proyecto (ajusta si quieres)
FILES_TO_DUMP=(
  "docker-compose.yml"
  "docker-compose.dev.yml"
  ".env"
  ".dockerignore"
  ".gitignore"
  "README.md"
  "docker-aliases.zsh"
  "exclude-for-prod.txt"
  "nginx/default.conf"
  "dockerfiles/nginx.dockerfile"
  "dockerfiles/php.dockerfile"
  "dockerfiles/php/opcache.ini"
  "dockerfiles/php/opcache-dev.ini"
  "mysql/.env.example"
  "mysql/.env"          # se incluye pero con redacción
  "src/.env.example"
)

# Empezar archivo
: > "$OUT_FILE"
{
  echo "📁 Estructura de '.'"
  echo "----------------------------------------"
  echo
  echo "📁 Árbol de directorios:"
} >> "$OUT_FILE"

# Árbol (usa tree si existe, si no usa find)
if command -v tree >/dev/null 2>&1; then
  (cd "$ROOT_DIR" && tree -a -I "$EXCLUDE_PATTERN") >> "$OUT_FILE"
else
  {
    echo "(tree no está instalado; usando find)"
    cd "$ROOT_DIR"
    find . \
      \( -path "./.git" -o -path "./mysql_data" -o -path "./mysql_dev_data" -o -path "./src/vendor" -o -path "./src/node_modules" -o -path "./src/storage" -o -path "./src/bootstrap/cache" -o -path "./.idea" -o -path "./.vscode" \) -prune \
      -o -print
  } >> "$OUT_FILE"
fi

{
  echo
  echo "----------------------------------------"
  echo
  echo "📄 Contenido de archivos relevantes:"
  echo
} >> "$OUT_FILE"

# Volcar archivos
for f in "${FILES_TO_DUMP[@]}"; do
  append_file "$f"
done

echo "OK -> generado: $OUT_FILE"

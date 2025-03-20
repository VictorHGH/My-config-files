#!/usr/bin/env zsh

# Definir colores
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# Verificar si se proporcionó un argumento
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide a course name.${RESET}"
    echo -e "Usage: start {ls|<course_name>}"
    exit 1
fi

# Definir el arreglo de cursos disponibles
cursos=(
    "develoteca_poo"
)

# Función para listar los cursos
function list_courses() {
    echo "Listing available courses:"
    echo ""

    num=1
    for curso in "${cursos[@]}"; do
        printf "${GREEN}%2d. %s${RESET}\n" "$num" "$curso"
        num=$((num + 1))
    done
}

# Función para verificar si un curso existe
function curso_existe() {
    local curso=$1
    for c in "${cursos[@]}"; do
        if [[ "$c" == "$curso" ]]; then
            return 0 # Curso encontrado
        fi
    done
    return 1 # Curso no encontrado
}

# Manejar diferentes opciones usando case
case "$1" in
    ls)
        list_courses
        ;;

    *)
        # Verificar si el curso existe
        if ! curso_existe "$1"; then
            echo -e "${RED}Error: Course '$1' not found.${RESET}"
            list_courses
            exit 1
        fi

        # Iniciar el curso correspondiente
        echo -e "${GREEN}Starting course: ${BLUE}$1${RESET}"
        tmuxinator start "$1"
        ;;
esac

import os
import re

# Patrones de exclusión
IGNORE_EXTENSIONS = r"\.(png|jpg|jpeg|pdf|gif|bmp|ico|svg|webp|mp4|mp3|wav|flac|ogg|zip|tar|gz|rar|7z|iso|bin|exe|dll|so|dylib|pyc|tex|db|log|woff2)$"
IGNORE_NAMES = r"(__pycache__|\.DS_Store|Thumbs\.db|node_modules|vendor|\.git|migrations_sqlite|materialize(\.min)?\.css|materialize(\.min)?\.js|jquery(\.min)?\.js|bootstrap(\.min)?\.css|bootstrap(\.min)?\.js)|salida\.txt|calculo_pdf|agregados_a_sabaticos\.txt|resultados_reunion_08_04_25|exclude-for-prod\.txt|porHacer\.txt|sabaticos_dev\.db|treecat\.py"


def is_ignored(path):
    """Determina si un archivo o carpeta debe ser ignorado."""
    name = os.path.basename(path)
    if re.search(IGNORE_NAMES, name):
        return True
    if os.path.isfile(path) and re.search(IGNORE_EXTENSIONS, path):
        return True
    # Excluir todo lo que esté dentro de .git o migrations_sqlite
    if any(ignored in path.split(os.sep) for ignored in [".git", "migrations_sqlite"]):
        return True
    return False


def generate_tree(directory, depth=None, single_level=False):
    """Genera un árbol de directorios filtrado."""
    tree_output = []
    if single_level:
        for entry in os.listdir(directory):
            full_path = os.path.join(directory, entry)
            if not is_ignored(full_path):
                tree_output.append(entry)
    else:
        for root, dirs, files in os.walk(directory):
            level = root[len(directory) :].count(os.sep)
            if depth is not None and level > depth:
                continue
            # Filtrar carpetas ignoradas
            dirs[:] = [d for d in dirs if not is_ignored(os.path.join(root, d))]
            indent = "│   " * (level - 1) + ("├── " if level > 0 else "")
            tree_output.append(f"{indent}{os.path.basename(root)}/")
            # Filtrar archivos ignorados
            for file in files:
                full_path = os.path.join(root, file)
                if not is_ignored(full_path) and os.path.getsize(full_path) < 50000:
                    tree_output.append(f"{'│   ' * level}├── {file}")
    return tree_output


def generate_txt(directory, output_file, depth=None, single_level=False):
    """Genera un archivo .txt con el árbol de directorios y contenido de archivos."""
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(f"📁 Estructura de '{directory}'\n")
        f.write("-" * 40 + "\n\n")

        # Árbol de directorios
        f.write("📁 Árbol de directorios:\n")
        tree = generate_tree(directory, depth, single_level)
        f.write("\n".join(tree))
        f.write("\n\n" + "-" * 40 + "\n\n")

        # Contenido de archivos relevantes
        f.write("📄 Contenido de archivos relevantes:\n")
        code_files = [
            os.path.join(root, file)
            for root, _, files in os.walk(directory)
            for file in files
            if not is_ignored(os.path.join(root, file))
            and os.path.getsize(os.path.join(root, file)) < 50000
        ]
        for file in code_files:
            f.write(f"\nArchivo: {file}\n")
            f.write("-" * 40 + "\n")
            try:
                with open(file, "r", encoding="utf-8", errors="ignore") as content:
                    text = content.read()
                    if not text.strip():  # Evitar archivos vacíos
                        f.write("El archivo está vacío.\n")
                    else:
                        f.write(text + "\n")
            except Exception as e:
                f.write(f"Error al leer el archivo: {file} ({e})\n")
            f.write("-" * 40 + "\n")
    print(f"✅ Archivo TXT generado: {output_file}")


def main():
    print("Bienvenido al generador de estructuras de proyectos.")
    directory = input("Ingrese la carpeta base (por defecto la actual): ") or "."
    if not os.path.isdir(directory):
        print(f"❌ Error: La carpeta '{directory}' no existe o no es un directorio.")
        return

    depth = input("Ingrese la profundidad máxima de directorios (opcional): ")
    depth = int(depth) if depth.isdigit() else None

    single_level = (
        input("¿Desea explorar solo un nivel de directorios? (s/n): ").lower() == "s"
    )

    output_name = (
        input("Ingrese el nombre del archivo de salida (sin extensión): ")
        or "superestructura"
    )
    output_file = f"{output_name}.txt"

    generate_txt(directory, output_file, depth, single_level)


if __name__ == "__main__":
    main()

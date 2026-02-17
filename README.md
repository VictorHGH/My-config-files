# Dotfiles

Configuracion personal de entorno de desarrollo gestionada con GNU Stow.

## Contenido del repositorio

- `global/`: configuraciones compartidas (zsh, git, tmux local, neovim).
- `arch/`: configuraciones especificas para Arch Linux (i3, i3status, etc.).
- `macbook_pro/`: ajustes para equipo macOS.
- `resources/`: manifiestos de paquetes (Homebrew/Pacman).
- `scripts/`: utilidades de mantenimiento y automatizacion.
- `tmuxinator/`: plantillas y scripts para sesiones de proyectos.

## Requisitos

- `git`, `stow`, `zsh`, `tmux`, `tmuxinator`
- Homebrew o Pacman segun sistema

## Instalacion rapida

1. Clona el repositorio en `~/dotfiles`.
2. Desde `~/dotfiles`, aplica modulos con `stow`:

```bash
stow global
```

En Arch puedes agregar:

```bash
stow arch global
```

3. Reinicia shell/tmux para cargar configuraciones.

## Manifiestos de paquetes

- Homebrew macOS: `resources/homebrew/Brewfile`
- Homebrew Linux: `resources/homebrew/Brewfile-linux`
- Pacman: `resources/pacman/packages.txt`

## Scripts utiles

- `scripts/upgrade.sh`: actualiza herramientas principales y manifiestos.
- `scripts/projects.zsh`: launcher de configuraciones tmuxinator con `fzf`.
- `scripts/treecat.py`: exporta arboles y contenido de carpetas.

## Tmuxinator

- `tmuxinator/start.zsh`: genera configuraciones por proyecto.
- `tmuxinator/template.yml`: base de sesiones.
- `tmuxinator/variables.zsh`: variables compartidas para templates.

## Buenas practicas

- Revisa `.stow-local-ignore` antes de stow para no enlazar carpetas no deseadas.
- Valida scripts y manifests antes de ejecutarlos en equipos nuevos.
- Mantener datos sensibles fuera de los dotfiles versionados.

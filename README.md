# Dotfiles

Configuracion personal de entorno de desarrollo gestionada con GNU Stow.

## Contenido del repositorio

- `global/`: configuraciones compartidas (zsh, git, neovim).
- `arch/`: ajustes de host para Arch desktop (modkey y overrides de i3).
- `macbook_pro/`: ajustes de host para Arch en MacBook (teclas multimedia, brillo, etc.).
- `mac_mini/`: ajustes de host para macOS en Mac mini (overrides de kitty).
- `resources/`: manifiestos de paquetes (Homebrew/Pacman/Termux).
- `scripts/`: utilidades de mantenimiento y automatizacion.

## Requisitos

- `git`, `stow`, `zsh`, `neovim`
- Homebrew o Pacman segun sistema

## Instalacion rapida

1. Ejecuta bootstrap segun perfil:

```bash
./scripts/bootstrap.sh --profile arch-desktop
```

Perfiles soportados:

- `arch-desktop` / `work-pc`
- `arch-macbook` / `macbook-pro`
- `mac-mini`
- `termux` / `redmi-a5`

2. Si prefieres manual, desde `~/dotfiles` aplica modulos con `stow`:

```bash
stow global
```

En Arch desktop:

```bash
stow arch global
```

En Arch MacBook:

```bash
stow macbook_pro global
```

En Mac mini:

```bash
stow global mac_mini
```

3. Reinicia shell para cargar configuraciones.

## Manifiestos de paquetes

- Homebrew macOS: `resources/homebrew/Brewfile`
- Homebrew Linux: `resources/homebrew/Brewfile-linux`
- Pacman: `resources/pacman/packages.txt`
- Termux: `resources/termux/packages.txt`

## Scripts utiles

- `scripts/bootstrap.sh`: prepara maquina nueva por perfil (paquetes, stow, instala Oh My Zsh si falta y zsh por defecto).
- En perfil Arch, `bootstrap.sh` instala el fix de teclado temprano para LUKS (`/usr/local/sbin/ensure-early-kbd`) y el hook `95-early-kbd.hook`.
- Modo prueba seguro: `./scripts/bootstrap.sh --profile arch-desktop --no-base-tools --no-packages --no-shell --no-update`
- `scripts/ensure-early-kbd.sh`: asegura modulos USB/HID en `mkinitcpio.conf` y reconstruye initramfs cuando hace falta.
- `scripts/upgrade.sh`: actualiza herramientas principales y manifiestos.
- `scripts/treecat.py`: exporta arboles y contenido de carpetas.

## i3 sin duplicacion

- Config comun: `resources/i3/config.shared`
- Host Arch desktop: `arch/.config/i3/config.host.conf`
- Host Arch MacBook: `macbook_pro/.config/i3/config.host.conf`

## Agregar nuevo perfil o sistema

1. Crea carpeta de host (ejemplo: `work_laptop/.config/i3/`) con `config` y `config.host.conf`.
2. Agrega el perfil al `case` en `scripts/bootstrap.sh` y define sus modulos de stow.
3. Si requiere paquetes nuevos, agrega manifiesto en `resources/` y enlazalo en `bootstrap.sh`.
4. Documenta el perfil en este README (seccion de perfiles soportados).

## Buenas practicas

- Revisa `.stow-local-ignore` antes de stow para no enlazar carpetas no deseadas.
- Valida scripts y manifests antes de ejecutarlos en equipos nuevos.
- Mantener datos sensibles fuera de los dotfiles versionados.

# Dotfiles

Configuracion personal gestionada con GNU Stow.

## Perfiles

- `arch`: escritorio Arch con i3.
- `mac-mini`: macOS con ajustes de Kitty.
- `termux`: configuracion global para Termux.

## Instalar en un equipo nuevo

```bash
git clone git@github.com:VictorHGH/My-config-files.git ~/dotfiles
cd ~/dotfiles
./scripts/bootstrap.sh --profile arch
```

Cambia `arch` por `mac-mini` o `termux` segun el equipo. Sin perfil, el script detecta la plataforma.

Oh My Zsh no se instala automaticamente. Si lo usas, clonalo en la revision fijada y revisala manualmente antes de ejecutar el bootstrap:

```bash
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git -C ~/.oh-my-zsh checkout --detach "$(< ~/dotfiles/resources/oh-my-zsh/commit)"
```

Para aplicar la configuracion manualmente:

```bash
stow global arch      # Arch
stow global mac_mini  # Mac mini
stow global           # Termux
```

## Arch

El perfil instala los paquetes oficiales de `resources/pacman/packages.txt`, prepara `yay` e instala los paquetes AUR de `resources/aur/packages.txt`. Tambien aplica `global` y `arch`. Los fixes de teclado temprano para LUKS y audio son opcionales con `--system-fixes`.

```bash
./scripts/bootstrap.sh --profile arch --system-fixes
```

La configuracion de i3 esta en `arch/.config/i3/config.shared`, con los ajustes del escritorio en `arch/.config/i3/config.host.conf`.

## Mantenimiento

- `scripts/bootstrap.sh`: instala paquetes y aplica el perfil.
- `scripts/upgrade.sh`: actualiza paquetes oficiales con Pacman y AUR con `yay`; exporta ambos manifiestos por separado.
- `scripts/audit.sh`: valida scripts, manifiestos, Stow, i3 y la revision de Oh My Zsh.
- `scripts/ensure-early-kbd.sh`: corrige el teclado temprano para LUKS en Arch.
- `scripts/treecat.py`: exporta arboles y contenido de directorios.

Las rutas y aliases personales deben ir en `~/.zshrc.local`, que no se versiona. Por ejemplo:

```bash
alias PG='cd ~/Documents/programacion'
```

Prueba el bootstrap sin cambios de sistema con:

```bash
./scripts/bootstrap.sh --profile arch --dry-run
```

Para revisar la actualizacion sin ejecutar comandos:

```bash
./scripts/upgrade.sh --dry-run
```

`upgrade.sh` guarda paquetes oficiales en `resources/pacman/packages.txt` y paquetes AUR en `resources/aur/packages.txt`.
Las exclusiones de cada manifiesto se guardan en `resources/pacman/exclude.txt` y `resources/aur/exclude.txt`; usalas para paquetes instalados localmente que no deben replicarse.

## Revision antes de actualizar

Ejecuta la auditoria y revisa los cambios propuestos:

```bash
./scripts/audit.sh
./scripts/upgrade.sh --dry-run
```

Antes de aceptar actualizaciones AUR, revisa sus cambios con `yay` y confirma que siguen siendo paquetes necesarios. Para actualizar Oh My Zsh, revisa los commits nuevos, actualiza `resources/oh-my-zsh/commit` solo si los aceptas y vuelve a ejecutar la auditoria:

```bash
git -C ~/.oh-my-zsh fetch --tags origin
git -C ~/.oh-my-zsh log --oneline "$(< ~/dotfiles/resources/oh-my-zsh/commit)..origin/master"
```

echo ""
echo ""
echo "    ██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗   "
echo "    ██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝   "
echo "    ██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗     "
echo "    ██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝     "
echo "    ╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗   "
echo "     ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝   "
echo "                                                                     "
echo "            ██╗   ██╗██╗ ██████╗████████╗ ██████╗ ██████╗            "
echo "            ██║   ██║██║██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗           "
echo "            ██║   ██║██║██║        ██║   ██║   ██║██████╔╝           "
echo "            ╚██╗ ██╔╝██║██║        ██║   ██║   ██║██╔══██╗           "
echo "             ╚████╔╝ ██║╚██████╗   ██║   ╚██████╔╝██║  ██║           "
echo "              ╚═══╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝           "
echo ""
echo "                       Let's build that shit.       "
echo ""
function general_options() {

  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export DISABLE_AUTO_TITLE="true"
  export SHELL_SESSIONS_DISABLE=1
  export LANG="en_US.UTF-8"
  export LC_ALL="en_US.UTF-8"
  export LC_CTYPE="en_US.UTF-8"
  export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

  # Change ZSH Options
  export EDITOR=nvim
  export VISUAL="$EDITOR"
  bindkey -v
  
  # Add Locations to $PATH Variables
  export PATH="/usr/local/sbin:$PATH"

  # Theme
  ZSH_THEME="3den"

  # General aliases
  alias c='clear'
  alias vic='nvim .'
  alias conf='nvim ~/.zshrc'
  alias confn='nvim ~/.config/nvim'
  alias upgrade='zsh ~/dotfiles/scripts/upgrade.sh'
  alias dot='nvim ~/dotfiles/'
  alias lazy='lazygit'
  alias run='~/dotfiles/scripts/projects.zsh'
  alias PG='~/Documents/programacion'
  alias copy='xclip -selection clipboard'
  alias spark='docker exec -w /var/www/html/ titulos_php php spark'
  alias starto='$HOME/dotfiles/tmuxinator/start.zsh'
}

function mac_options() {
  #Paths
  export PATH="$(brew --prefix)/opt/python@3.11/libexec/bin:$PATH"
  export PATH="/opt/homebrew/opt/gnupg@2.2/bin:$PATH"
  export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"

  #gpg
  export GPG_TTY=$(tty)

  # Oh-my-zsh
  export ZSH="/Users/$USERNAME/.oh-my-zsh"
  source $ZSH/oh-my-zsh.sh

  # FMN
  eval "$(fnm env --use-on-cd)"

  #############################
  ##### Oh my zsh plugins #####
  #############################
  
  plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-vi-mode
    pass
  )

  ###################
  ##### Aliases #####
  ###################

  # Maestria
  alias MA='cd ~/Documents/Maestria/'
  alias icr='cd ~/Documents/Maestria/Investigacion\ general/ICR/ICR/'

  # Programacion
  alias password='python3 /Users/$USERNAME/Documents/programacion/python/passwords/pass.py'
}

function linux_options() {

  setxkbmap -layout us -variant altgr-intl
  setxkbmap -option caps:escape
  # xinput set-prop 9 313 1
  export PATH=$PATH:/opt/lampp/bin

  # Homebrew
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  # FMN
  eval "$(fnm env --use-on-cd)"

  # Oh-my-zsh
  export ZSH="/home/$USERNAME/.oh-my-zsh"
  source $ZSH/oh-my-zsh.sh

  plugins=(
    git
	tmuxinator
	pipenv
	fnm
	laravel
	brew
	node
	vi-mode
	zsh-interactive-cd
  )
  
  # Aliases
  alias icr='cd ~/Documents/programacion/maestria/ICR/'
}

function setup_kitty_vi_cursor() {
  [[ -z "$KITTY_WINDOW_ID" ]] && return

  function zle-keymap-select() {
    case "$KEYMAP" in
      vicmd) printf '\e[1 q' ;;
      *) printf '\e[5 q' ;;
    esac
  }

  function zle-line-init() {
    printf '\e[5 q'
  }

  function zle-line-finish() {
    printf '\e[5 q'
  }

  zle -N zle-keymap-select
  zle -N zle-line-init
  zle -N zle-line-finish
}

if [[ "$OSTYPE" == "darwin"* ]] then
  # Mac OSX
  general_options
  mac_options
elif [[ "$OSTYPE" == "linux"* ]] then
  # Linux
  general_options
  linux_options
else
  echo "Unknown Operating system. Exiting."
  exit 1
fi

setup_kitty_vi_cursor

# opencode
export PATH=/home/$USER/.opencode/bin:$PATH

# opencode
export PATH=/Users/VictorHGH/.opencode/bin:$PATH

function show_banner() {
  cat <<'EOF'


    ██╗   ██╗██╗  ██╗ ██████╗ ██╗  ██╗
    ██║   ██║██║  ██║██╔════╝ ██║  ██║
    ██║   ██║███████║██║  ███╗███████║
    ╚██╗ ██╔╝██╔══██║██║   ██║██╔══██║
     ╚████╔╝ ██║  ██║╚██████╔╝██║  ██║
      ╚═══╝  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝
EOF
echo ""
echo "          Let's build that shit!"
echo ""
}

show_banner

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
  alias PG='~/Documents/programacion'
  alias spark='docker exec -w /var/www/html/ titulos_php php spark'

  if command -v xclip >/dev/null 2>&1; then
    alias copy='xclip -selection clipboard'
  elif command -v pbcopy >/dev/null 2>&1; then
    alias copy='pbcopy'
  elif command -v termux-clipboard-set >/dev/null 2>&1; then
    alias copy='termux-clipboard-set'
  fi
}

function mac_options() {
  #Paths
  export PATH="$(brew --prefix)/opt/python@3.11/libexec/bin:$PATH"
  export PATH="/opt/homebrew/opt/gnupg@2.2/bin:$PATH"
  export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"

  #gpg
  export GPG_TTY=$(tty)

  # Oh-my-zsh
  export ZSH="$HOME/.oh-my-zsh"
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
  alias password='python3 $HOME/Documents/programacion/python/passwords/pass.py'
}

function linux_options() {

  if [[ -n "${DISPLAY:-}" ]] && command -v setxkbmap >/dev/null 2>&1; then
    setxkbmap -layout us -variant altgr-intl
    setxkbmap -option caps:escape
  fi
  # xinput set-prop 9 313 1
  export PATH=$PATH:/opt/lampp/bin

  # Homebrew
  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  # FMN
  if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd)"
  fi

  # Oh-my-zsh
  export ZSH="$HOME/.oh-my-zsh"
  source $ZSH/oh-my-zsh.sh

  plugins=(
    git
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

function termux_options() {
  export ZSH="$HOME/.oh-my-zsh"
  source $ZSH/oh-my-zsh.sh

  if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd)"
  fi

  plugins=(
    git
    vi-mode
  )
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

if [[ "$OSTYPE" == "darwin"* ]]; then
  # Mac OSX
  general_options
  mac_options
elif [[ -n "${TERMUX_VERSION:-}" ]] || [[ "${PREFIX:-}" == "/data/data/com.termux/files/usr" ]]; then
  # Termux
  general_options
  termux_options
elif [[ "$OSTYPE" == "linux"* ]]; then
  # Linux
  general_options
  linux_options
else
  echo "Unknown Operating system. Exiting."
  exit 1
fi

setup_kitty_vi_cursor

if [[ -d "$HOME/.opencode/bin" ]]; then
  export PATH="$HOME/.opencode/bin:$PATH"
fi

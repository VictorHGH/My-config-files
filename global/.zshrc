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
  
  # Add Locations to $PATH Variables
  export PATH="/usr/local/sbin:$PATH"

  # Theme
  ZSH_THEME="3den"

  # NeoFetch
  echo ""
  neofetch

  # General aliases
  alias c='clear'
  alias vic='nvim .'
  alias conf='nvim ~/.zshrc'
  alias confn='nvim ~/.config/nvim'
  alias upgrade='zsh ~/dotfiles/scripts/upgrade.sh'
  alias dot='nvim ~/dotfiles/'
  alias lazy='lazygit'
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
  alias proto='nvim ~/Documents/Maestria/ICRyProto/protocolo/estructura/'
  alias icr='nvim ~/Documents/Maestria/ICRyProto/ICR/estructura/'
  alias MA='nvim ~/Documents/Maestria/4to_trimestre/Clases/'

  # Programacion
  alias PG='/Users/$USERNAME/Documents/programacion_2.0'
  alias sqli='litecli *.db'
  alias password='python3 /Users/$USERNAME/Documents/programacion_2.0/python/passwords/pass.py'
  alias exif='/Users/$USERNAME/Documents/programacion_2.0/scripts/exif.sh'
  alias math='zsh ~/Documents/programacion_2.0/scripts/math.sh'
  alias notas='open ~/Documents/musica/Notas\ musicales/*.png'
  alias udemy='nvim ~/Documents/programacion_2.0/PSeInt/Curso\ Udemy/012_C++'

  # Tmuxinator
  alias arquipat='tmuxinator start arquipat'
  alias threejs='tmuxinator start threejs'
  alias tk='tmuxinator start tk'
  alias respon='tmuxinator start Responsive'
  alias cs50='tmuxinator start CS50'
  alias astro='tmuxinator start astro'
  alias webc='tmuxinator start WebComponents'
  alias course="tmuxinator start youtube_course_mac"
}

function linux_options() {

  setxkbmap -layout us -variant altgr-intl
  setxkbmap -option caps:escape
  xinput set-prop 8 "libinput Natural Scrolling Enabled" 1

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
  alias PG='cd ~/Documents/programacion/'
  alias respon='cd ~/Documents/programacion_2.0/responsiveUdemy && tmuxinator start Responsive'
  alias xs='sudo /opt/lampp/lampp startapache && sudo /opt/lampp/lampp startmysql'
  alias xc='sudo /opt/lampp/lampp stopapache && sudo /opt/lampp/lampp stopmysql'
  alias copy='xclip -selection clipboard'

  # Tmuxinator
  alias course="tmuxinator start youtube_course_arch"
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

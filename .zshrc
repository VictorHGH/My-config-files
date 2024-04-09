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
# Set Variables
# Syntax highlighting for man pages using bat
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
export PATH="/usr/local/opt/gnupg@2.2/bin:$PATH"

# FNM
eval "$(fnm env --use-on-cd)"

#gpg
export GPG_TTY=$(tty)

# Write Handy Functions
function mkcd(){
  mkdir -p "$@" && cd "$_"
}
# ...and Other Surprises 

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/$USERNAME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="3den"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-vi-mode
  pass
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias proto='nvim ~/Documents/Maestria/ICRyProto/protocolo/estructura/'
alias icr='nvim ~/Documents/Maestria/ICRyProto/ICR/estructura/'
alias MA='nvim ~/Documents/Maestria/4to_trimestre/Clases/'

# Programacion
alias ub='brew upgrade `brew outdated`'
alias c='clear'
alias PG='/Users/$USERNAME/Documents/programacion_2.0'
alias vic='nvim .'
alias conf='nvim ~/.zshrc'
alias confn='nvim ~/.config/nvim'
alias sqli='litecli *.db'
alias password='python3 /Users/$USERNAME/Documents/programacion_2.0/python/passwords/pass.py'
alias exif='/Users/$USERNAME/Documents/programacion_2.0/scripts/exif.sh'
alias math='zsh ~/Documents/programacion_2.0/scripts/math.sh'
alias notas='open ~/Documents/musica/Notas\ musicales/*.png'
alias upgrade='zsh ~/Documents/programacion_2.0/scripts/upgrade.sh'
alias udemy='nvim ~/Documents/programacion_2.0/PSeInt/Curso\ Udemy/012_C++'
alias astro='tmuxinator start astro'

# Tmuxinator
alias arquipat='tmuxinator start arquipat'
alias threejs='tmuxinator start threejs'
alias tk='tmuxinator start tk' 
alias respon='tmuxinator start Responsive'
alias cs50='tmuxinator start CS50' 

# Export PATH
export PATH="/opt/homebrew/opt/gnupg@2.2/bin:$PATH"
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"

# Python
export PATH="$(brew --prefix)/opt/python@3.11/libexec/bin:$PATH"

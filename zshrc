PROMPT="[%F{green}%n%f@%F{red}%m%f] || (%F{cyan}%~%f) : "

########################################################
# Configuration
########################################################

COLOR_BLACK="\e[0;30m"
COLOR_BLUE="\e[0;34m"
COLOR_GREEN="\e[0;32m"
COLOR_CYAN="\e[0;36m"
COLOR_PINK="\e[0;35m"
COLOR_RED="\e[0;31m"
COLOR_PURPLE="\e[0;35m"
COLOR_BROWN="\e[0;33m"
COLOR_LIGHTGRAY="\e[0;37m"
COLOR_DARKGRAY="\e[1;30m"
COLOR_LIGHTBLUE="\e[1;34m"
COLOR_LIGHTGREEN="\e[1;32m"
COLOR_LIGHTCYAN="\e[1;36m"
COLOR_LIGHTRED="\e[1;31m"
COLOR_LIGHTPURPLE="\e[1;35m"
COLOR_YELLOW="\e[1;33m"
COLOR_WHITE="\e[1;37m"
COLOR_NONE="\e[0m"

# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY          # write the history file in the ":start:elapsed;command" format.
setopt HIST_REDUCE_BLANKS        # remove superfluous blanks before recording entry.
setopt SHARE_HISTORY             # share history between all sessions.
setopt HIST_IGNORE_ALL_DUPS      # delete old recorded entry if new entry is a duplicate.

setopt COMPLETE_ALIASES

bindkey "^A" vi-beginning-of-line
bindkey -M viins "^F" vi-forward-word # [Ctrl-f] - move to next word
bindkey -M viins "^E" vi-add-eol      # [Ctrl-e] - move to end of line
bindkey "^J" history-beginning-search-forward
bindkey "^K" history-beginning-search-backward

# add color to man pages
export MANROFFOPT='-c'
export LESS_TERMCAP_mb=$(tput bold; tput setaf 2)
export LESS_TERMCAP_md=$(tput bold; tput setaf 6)
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7)
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)

########################################################
# Aliases
########################################################

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # macOS `ls`
    colorflag="-G"
fi

# export PATH
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/share/python:$PATH
export PATH=/usr/local/bin:/usr/local/sbin:~/bin:$PATH

# bants
alias please="sudo"

# Filesystem aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias l="ls -lah ${colorflag}"
alias la="ls -AF ${colorflag}"
alias ll="ls -alFh ${colorflag}"
alias lld="ls -l | grep ^d"
alias rm="rm -iv"
alias rmf="rm -rf"
alias history="history 1"

# Helpers
alias grep="grep --color=auto"
alias df="df -h" # disk free, in Gigabytes, not bytes
alias du="du -h -c" # calculate disk usage for a folder

# vim aliases
alias vi="nvim"
alias vim="nvim"

# python aliases
alias python="python3"
alias pip="pip3"

# venv aliases and utils
export WORKON_HOME="/Users/tasa/venvs"
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3.8
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
alias venv="mkvirtualenv"
alias lsvenv="lsvirtualenv"
source "/usr/local/bin/virtualenvwrapper.sh"

# exports for React-Native development
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# tmux aliases
alias tls="tmux ls"
alias tat="tmux attach -t"
alias tns="tmux new-session -s"

# functions 

function name {
  echo -ne "\e]1;$1 $2 $3 $4 $5 $6 $7 $8 $9\a"
}

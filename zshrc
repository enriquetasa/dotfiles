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

# Aliases

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
export PATH=/Library/Python/3.7/bin:$PATH

# bants
alias please="sudo"
alias unimente="ssh tasa@unimente.enriquetasa.com -p 69"

# ls aliases
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

# git aliases
alias clean_git="git branch --merged | egrep -v '(^\*|master|develop)' | xargs git branch -d"

# venv aliases and utils
export WORKON_HOME="/Users/tasa/venvs"
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3.9
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

# open vscode from cli
alias code="open -a /Applications/Visual\ Studio\ Code.app"

# functions 
function name {
  echo -ne "\e]1;$1 $2 $3 $4 $5 $6 $7 $8 $9\a"
}

# exports
export DJANGO_DEVELOPMENT=True

plugins=(git macos python)
export ZSH="/Users/tasa/.oh-my-zsh"
ZSH_THEME="robbyrussell"
COMPLETION_WAITING_DOTS="true"
source $ZSH/oh-my-zsh.sh

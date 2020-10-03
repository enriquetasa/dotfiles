[[ $- == *i* ]] || return 

# Aliases #############################################################################################

# ls aliases
alias ll='ls -alh'
alias l='ls'
alias s='ls'
alias sl='ls'
alias cls='clear && ls'

alias python='python3'
alias pip='pip3'

alias vi='nvim'
alias tmux='tmux -2'

# grep & ag aliases
alias grep='grep --color=auto'
alias ag='ag --path-to-ignore ~/.ignore'

# cd aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# rm aliases
alias rm='rm -iv'

# classic
alias please='sudo'

# End of Aliases ########################################################################################

# Colours
export TERM=xterm-color
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# history config
export HISTFILESIZE=20000
export HISTSIZE=10000
# Ignore duplicates, ls without options and builtin commands
HISTCONTROL=ignoredups
export HISTIGNORE="&:ls:[bf]g:exit"

clear

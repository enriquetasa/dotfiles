[[ $- == *i* ]] || return 

# Aliases #############################################################################################

# ls aliases
alias ls='ls --color=auto'
alias ll='ls -alh'
alias l='ls'
alias s='ls'
alias sl='ls'
alias cls='clear && ls'

alias python='python3'
alias pip='pip3'

alias vi='neovim'
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

#Bash prompt
export PS1="[\[\e[31m\]\u\[\e[m\]@\[\e[32m\]\h\[\e[m\]]|[\[\e[36m\]\w\[\e[m\]\[\e[37m\]]\[\e[m\]: "

# history config
export HISTFILESIZE=20000
export HISTSIZE=10000
shopt -s histappend
# Combine multiline commands into one in history
shopt -s cmdhist
# Ignore duplicates, ls without options and builtin commands
HISTCONTROL=ignoredups
export HISTIGNORE="&:ls:[bf]g:exit"

clear

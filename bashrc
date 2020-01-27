# DAI Specific stuff ##################################################################################
. ~/source/ut_profile.sh
alias rebuild="sm_sysman noninteractive shutdown && ut_sys_build && sm_startup --yes-to-all"
#######################################################################################################

# Aliases #############################################################################################

# ls aliases
alias ll='ls -alh'
alias l='ls'
alias s='ls'
alias sl='ls'
alias ls='ls --color=auto'
alias cls='clear && ls'
alias python='python3'
alias pip='pip3'

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

# always use cgdb
alias gdb='cgdb'

# End of Aliases ########################################################################################

# Bash prompt
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

if [ "$TERM" = "linux" ]; then
    echo -en "\e]P0073642" #black
    echo -en "\e]P1DC322F" #darkred
    echo -en "\e]P2859900" #darkgreen
    echo -en "\e]P3B58900" #brown
    echo -en "\e]P4268BD2" #darkblue
    echo -en "\e]P5D33682" #darkmagenta
    echo -en "\e]P62AA198" #darkcyan
    echo -en "\e]P7EEE8D5" #lightgrey
    echo -en "\e]P8002B36" #darkgrey
    echo -en "\e]P9CB4B16" #red
    echo -en "\e]PA586E75" #green
    echo -en "\e]PB657B83" #yellow
    echo -en "\e]PC839496" #blue
    echo -en "\e]PD6C71C4" #magenta
    echo -en "\e]PE93A1A1" #cyan
    echo -en "\e]PFFDF6E3" #white
    clear #for background artifacting
fi

export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export TERM=xterm-256color

clear

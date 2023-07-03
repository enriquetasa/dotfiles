# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY          # write the history file in the ":start:elapsed;command" format.
setopt HIST_REDUCE_BLANKS        # remove superfluous blanks before recording entry.
setopt SHARE_HISTORY             # share history between all sessions.
setopt HIST_IGNORE_ALL_DUPS      # delete old recorded entry if new entry is a duplicate.
setopt COMPLETE_ALIASES

# keybindings
bindkey "^A" vi-beginning-of-line
bindkey -M viins "^F" vi-forward-word # [Ctrl-f] - move to next word
bindkey -M viins "^E" vi-add-eol      # [Ctrl-e] - move to end of line
bindkey "^J" history-beginning-search-forward
bindkey "^K" history-beginning-search-backward

# aliases
alias ll="ls -alHG ${colorflag}"
alias grep="grep --color=auto"
alias agl="ag -l"
alias vi="nvim"
alias vim="nvim"
alias zshrc="vi ~/code/dotfiles/zshrc"
alias vimrc="vi ~/code/dotfiles/init.vim"
alias ignore="vi ~/.ignore" 

# git
alias gitfixup="git commit --edit --fixup"
alias gitwip="git commit -m 'RESET ME [skip ci]' -n"

# venv
export WORKON_HOME="~/venvs"
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export VIRTUALENVWRAPPER_VIRTUALENV=/opt/homebrew/bin/virtualenv
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
alias venv="mkvirtualenv"
alias lsvenv="lsvirtualenv"
source "/opt/homebrew/bin/virtualenvwrapper.sh"

# tmux
alias tls="tmux ls"
alias tat="tmux attach -t"
alias tns="tmux new-session -s"

# vscode
alias code="open -a /Applications/Visual\ Studio\ Code.app"

# oh my zsh
plugins=(git macos python colored-man-pages pip)
export ZSH="/Users/tasa/.oh-my-zsh"
ZSH_THEME="robbyrussell"
COMPLETION_WAITING_DOTS="true"
source $ZSH/oh-my-zsh.sh

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pyenv
eval "$(pyenv init -)"

# octopus
alias run_support="DJANGO_CONFIGURATION=OEESSupportSite honcho start -f Procfile.supportsite"
alias run_migrations="DJANGO_CONFIGURATION=OEESMigrations DJANGO_SETTINGS_MODULE=localdev.settings ./manage.py migrate --database=default"
alias run_tests="DJANGO_SETTINGS_MODULE=tests.settings pytest"
export TENTACLIO__SECRETS_FILE=~/.tentaclio.yml # tentaclio secrets file
export PIPENV_VERBOSITY=-1

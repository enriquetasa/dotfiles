# history
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
HISTORY_IGNORE="(ls|cd|pwd|exit|clear|history|fg|bg|jobs)"
setopt EXTENDED_HISTORY          # write the history file in the ":start:elapsed;command" format.
setopt HIST_REDUCE_BLANKS        # remove superfluous blanks before recording entry.
setopt SHARE_HISTORY             # share history between all sessions.
setopt HIST_IGNORE_ALL_DUPS      # delete old recorded entry if new entry is a duplicate.
setopt COMPLETE_ALIASES

# prompt
export PS1="%{$(tput setaf 39)%}%n%{$(tput setaf 81)%}@%{$(tput setaf 77)%}%m %{$(tput setaf 226)%}%1~ %{$(tput sgr0)%}$ "

# oh my zsh
plugins=(
   git
   python
   colored-man-pages
   pip
   direnv
   history
   thefuck
)
ZSH_THEME="obraun"
COMPLETION_WAITING_DOTS="true"
source ~/.oh-my-zsh/oh-my-zsh.sh

# aliases
alias ll="ls -alHG ${colorflag}"
alias grep="grep --color=auto"
alias vi="nvim"
alias zshrc="nvim ~/.zshrc"
alias vimrc="nvim ~/.vimrc"
alias venv="echo 'layout python3' > .envrc && direnv allow"

# vim
export EDITOR="nvim"

# macOS detection
if [[ "$OSTYPE" == darwin* ]]; then
   # vscode
   alias code="open -a /Applications/Visual\ Studio\ Code.app"
   # homebrew python
   export PATH="/opt/homebrew/opt/python@3.13/bin:$PATH"
   export PYTHON_GLOBAL="/opt/homebrew/opt/python@3.13/bin/python3"
   export PIP_GLOBAL="/opt/homebrew/opt/python@3.13/bin/pip3"
fi


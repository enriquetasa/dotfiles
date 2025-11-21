# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY          # write the history file in the ":start:elapsed;command" format.
setopt HIST_REDUCE_BLANKS        # remove superfluous blanks before recording entry.
setopt SHARE_HISTORY             # share history between all sessions.
setopt HIST_IGNORE_ALL_DUPS      # delete old recorded entry if new entry is a duplicate.
setopt COMPLETE_ALIASES

# aliases
alias ll="ls -alHG ${colorflag}"
alias grep="grep --color=auto"
alias agl="ag -l"
alias vi="nvim"
alias vim="nvim"
alias zshrc="vi ~/code/dotfiles/zshrc"
alias vimrc="vi ~/code/dotfiles/init.vim"
alias ignore="vi ~/.ignore" 
alias dotfiles="cd ~/code/dotfiles"
alias venv="echo 'layout python3' > .envrc && direnv allow"

# git
alias gitconfig="vi ~/.gitconfig"
alias gitfixup="git commit --edit --fixup"
alias gitwip="git commit -m 'RESET ME [skip ci]' -n"
function rebase_with_master(){
     current_branch="$(git branch | awk '/\*/ { print $2; }')"
     print $current_branch
     git checkout master
     git pull --rebase
     git checkout $current_branch
     git rebase master
   }
function rebase_with_main(){
     current_branch="$(git branch | awk '/\*/ { print $2; }')"
     print $current_branch
     git checkout main
     git pull --rebase
     git checkout $current_branch
     git rebase main
  }
alias gitlog="git log --oneline --decorate --reverse -n 40"

# virtualenvironments
eval "$(direnv hook zsh)"

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
export TENTACLIO__SECRETS_FILE=~/.tentaclio.yml # tentaclio secrets file
export PIPENV_VERBOSITY=-1
function inv_checks(){
   inv run-python-type-checker 
   inv run-python-flake8-linter
}

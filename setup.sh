#!/bin/bash

pause_until_enter() {
  read -r -p "Press Enter to continue..."
}

echo "Starting system setup"


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" # DIR is the directory of this script
echo "This script is in: $DIR" 

sudo chmod 777 -R $DIR

# linux setup
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Linux system detected"
    pause_until_enter
    sudo apt update
    sudo apt upgrade
    sudo apt install -y tmux python3 python3-pip python3-venv \
     tmux zsh nodejs golang postgresql nginx curl git build-essential \
     ripgrep wget ca-certificates gnupg lsb-release make cmake fd-find \
     fzf unzip zip 
    sudo apt autoremove
    sudo apt autoclean
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
    echo "Installed Linux configuration"

# macOS setup
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macOS system detected"
    pause_until_enter
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    brew update
    brew upgrade
    brew install git neovim tmux python pynvim
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
    echo "Installed brew, macOS configuration, nvim and tmux"

else 
    echo "Can't recognise this OS"
    return
fi

# git setup
cp $DIR/gitconfig ~/.gitconfig
cp $DIR/git_commit_template.txt ~/.git_commit_template

# zsh setup
touch ~/.zshenv
touch ~/.zsh_profile
touch ~/.zshlogin
touch ~/.zshlogout
cp $DIR/zshrc ~/.zshrc
chsh -s $(which zsh)
exec zsh

# nvim 
export EDITOR='nvim'
export VISUAL='nvim'
nvim

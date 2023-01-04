#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo $DIR

echo "Starting system setup"

sudo chmod 555 -R $DIR

# system updates and upgrades, neovim
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Linux system detected"
    sudo apt update
    sudo apt upgrade
    sudo apt install neovim
    sudo apt install tmux
    sudo apt install zsh
    sudo apt install nodejs
    sudo apt install golang
    sudo apt install postgresql
    sudo apt install nginx
    pip3 install pynvim
    sudo apt autoremove
    sudo apt autoclean
    echo "Installed Linux configuration, nvim and tmux"
        
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macOS system detected"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    brew update
    brew upgrade
    brew install neovim
    brew install tmux
    brew install python
    pip3 install pynvim
    echo "Installed brew, macOS configuration, nvim and tmux"
else 
    echo "Can't recognise this OS"
    return
fi

# dotfiles - TODO symlinks don't work for some reason
echo "Symlinking dotfiles"
ln -sf $DIR/zshrc ~/.zshrc
touch ~/.zshenv
touch ~/.zsh_profile
touch ~/.zshlogin
touch ~/.zshlogout
ln -sf $DIR/tmux.conf ~/.tmux.conf
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Legacy
# ln -sv /dotfiles/.bashrc ~
# ln -sv /dotfiles/.bash_profile ~
# ln -sv /dotfiles/.vimrc ~

echo "Configuring nvim"
mkdir ~/.config/nvim
mkdir ~/.config/nvim/plugged
mkdir ~/.config/nvim/autoload
sh -c 'curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
ln -sf $DIR/init.vim ~/.config/nvim/init.vim
nvim -c "PlugInstall"
export EDITOR='nvim'
export VISUAL='nvim'

chsh -s $(which zsh)

pip install virtualenvwrapper
export WORKON_HOME=~/venvs
mkdir -p $WORKON_HOME
source /usr/local/bin/virtualenvwrapper.sh

echo "Set up successful, you'll have to logout and back in for shell changes to take place"

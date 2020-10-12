#!/bin/bash

echo "Starting system setup"

sudo chmod 555 -R /dotfiles

# system updates and upgrades, neovim
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Linux system detected"
    sudo apt update
    sudo apt upgrade
    sudo apt install neovim
    sudo apt install tmux
    sudo apt install zsh
    sudo apt autoremove
    sudo apt autoclean
    echo "Installed Linux configuration, nvim and tmux"
        
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macOS system detected"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    brew update
    brew upgrade
    brew install zsh
    brew install neovim
    brew install tmux
    echo "Installed brew, macOS configuration, nvim and tmux"
else 
    echo "Can't recognise this OS"
    return
fi

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# dotfiles - TODO symlinks don't work for some reason
echo "Symlinking dotfiles"
ln -sf /dotfiles/zshrc ~/.zshrc
touch ~/.zshenv
touch ~/.zsh_profile
touch ~/.zshlogin
touch ~/.zshlogout
ln -sf /dotfiles/tmux.conf ~/.tmux.conf

# Legacy
# ln -sv /dotfiles/.bashrc ~
# ln -sv /dotfiles/.bash_profile ~
# ln -sv /dotfiles/.vimrc ~

echo "Configuring nvim"
if [ ! -d "~/.config/nvim/" ] 
then
    mkdir ~/.config/nvim
fi
ln -sf /dotfiles/init.vim ~/.config/nvim/init.vim
nvim -c "PlugInstall"
export EDITOR='nvim'
export VISUAL='nvim'

chsh -s $(which zsh)

echo "Set up successful, you'll have to logout and back in for shell changes to take place"

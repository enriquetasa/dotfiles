#!/bin/bash 

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" # DIR is the directory of this script
sudo chmod 777 -R $DIR

# install oh-my-zsh
if not [[ "$OSTYPE" == "darwin"* ]]; then
    # TODO: exit the program
    

read -r -p "Press ENTER to install OH-MY-ZSH"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# zsh setup
touch ~/.zshenv
touch ~/.zsh_profile
touch ~/.zshlogin
# TODO: on login, we should launch straight into tmux
touch ~/.zshlogout
cp $DIR/zshrc ~/.zshrc # TODO: this is actually a directory up
echo "OH MY ZSH installed and configured successfully\n\n"

# install homebrew
read -r -p "Press ENTER to install Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
# TODO: set up PATH and links
echo "Homebrew installed correctly\n\n"

# use homebrew to install:
# 1. git, tmux, python3
read -r -p "Press ENTER to install CLI tooling"
brew install git tmux python 
# git setup
touch ~/.gitconfig
touch ~/.git_commit_template
cp $DIR/gitconfig ~/.gitconfig
cp $DIR/git_commit_template.txt ~/.git_commit_template
echo "Installed and configured git, tmux and Python\n"

# 2. neovim tooling
read -r -p "Press ENTER to install neovim environment"
brew install neovim pynvim fd-find ripgrep fzf unzip zip
# vim 
mkdir ~/.config/nvim/
cp $DIR/vimrc ~/.config/nvim/init.vim
export EDITOR='nvim'
export VISUAL='nvim'
echo "Installed and configured nvim and its plugins\n"



read -r -p "Cleaning up Homebrew, press ENTER to proceed"
# TODO: Do we really need to update and upgrade? I'd rather we clean up, no?
brew update
brew upgrade
echo "Homebrew cleaned up\n"

# TODO: TODO list post this
chsh -s $(which zsh)

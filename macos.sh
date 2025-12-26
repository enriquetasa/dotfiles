#!/bin/bash

# DIR is the directory of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
sudo chmod 777 -R $DIR

read -r -p "Press ENTER to install OH-MY-ZSH"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# zsh setup
touch ~/.zshenv
touch ~/.zshprofile
touch ~/.zshrc
touch ~/.zsh_history
cp $DIR/zsh/zshenv ~/.zshenv
cp $DIR/zsh/zshprofile ~/.zshprofile
cp $DIR/zsh/zshrc ~/.zshrc
echo "OH MY ZSH installed and configured successfully\n\n"

# install homebrew
read -r -p "Press ENTER to install Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
echo "Homebrew installed correctly\n\n"

# git, tmux, python3
read -r -p "Press ENTER to install CLI tooling"
brew install git tmux python3 thefuck direnv
# git setup
touch ~/.gitconfig
touch ~/.git_commit_template
touch ~/.tmux.conf
cp $DIR/git/gitconfig ~/.gitconfig
cp $DIR/git/git_commit_template.txt ~/.git_commit_template
cp $DIR/tmux/tmux.conf ~/.tmux.conf
echo "Installed and configured git, tmux and Python\n"

# neovim
read -r -p "Press ENTER to install neovim environment"
brew install neovim pyvim fd ripgrep fzf unzip zip wget
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim
echo "Installed and configured nvim and its plugins\n"

chsh -s $(which zsh)
exec zsh

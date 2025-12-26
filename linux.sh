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

# git, tmux, python3
read -r -p "Press ENTER to install CLI tooling"
sudo apt update
apt upgrade
apt install git tmux python3 thefuck direnv python3-pip python3-venv \
  zsh nodejs golang postgresql nginx curl build-essential \
  ripgrep wget ca-certificates gnupg lsb-release make cmake fd-find \
  fzf unzip zip
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
apt install -y neovim pyvim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim
echo "Installed and configured nvim and its plugins\n"

read -r -p "Cleaning up apt, press ENTER to proceed"
apt autoremove
apt autoclean
echo "apt cleaned up\n"

chsh -s $(which zsh)
exec zsh

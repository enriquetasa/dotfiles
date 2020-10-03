echo "Modify this file to allow for username and for selection of vim/neovim and run again"
echo ". /Users/etasa/dotfiles/bashrc" > ~/.bashrc
echo ". /Users/etasa/dotfiles/zshrc" > ~/.zshrc
echo ":source /Users/etasa/dotfiles/vimrc" > ~/.vimrc
mkdir /Users/etasa/.config/nvim/
echo ":source /Users/etasa/dotfiles/init.vim" > /Users/etasa/.config/nvim/init.vim
echo ". /Users/etasa/dotfiles/ignore" > ~/.ignorerc
echo ". /Users/etasa/dotfiles/bash_profile" > ~/.bash_profile
echo "source-file /Users/etasa/dotfiles/tmux.conf" > ~/.tmux.conf

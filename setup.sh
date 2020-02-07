sudo chmod 777 -R .
echo ". /dotfiles/bashrc" > ~/.bashrc
echo ":source /dotfiles/vimrc" > ~/.vimrc
echo ". /dotfiles/screenrc" > ~/.screenrc
echo ". /dotfiles/cgbdrc" > ~/.cgbdrc
echo ". /dotfiles/ignore" > ~/.ignorerc
echo ". /dotfiles/bash_profile" > ~/.bash_profile
echo "source-file /dotfiles/tmux.conf" > ~/.tmux.conf
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
vim +PluginInstall +qall
sudo python ~/.vim/bundle/youcompleteme/install.py
echo "Check for the dotfiles directory permissions and the compilation of YCM"

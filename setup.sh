echo ". /tasa_utilities/bashrc" > ~/.bashrc
echo ":source /tasa_utilities/vimrc" > ~/.vimrc
echo ". /tasa_utilities/screenrc" > ~/.screenrc
echo ". /tasa_utilities/cgbdrc" > ~/.cgbdrc
echo ". /tasa_utilities/ignore" > ~/.ignorerc
echo ". /tasa_utilities/bash_profile" > ~/.bash_profile
echo ". /tasa_utilities/tmux.conf" > ~/.tmux.conf
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
vim +PluginInstall +qall
echo "Remember to chmod the tasa_utilities directory and compile YCM stuff"

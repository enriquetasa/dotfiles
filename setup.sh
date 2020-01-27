chmod -R 777 /tasa_utilities/
echo ". /tasa_utilities/bashrc" > ~/.bashrc
echo ":source /tasa_utilities/vimrc" > ~/.vimrc
echo ". /tasa_utilities/screenrc" > ~/.screenrc
echo ". /tasa_utilities/cgbdrc" > ~/.cgbdrc
echo ". /tasa_utilities/ignore" > ~/.ignorerc
echo ". /tasa_utilities/bashprofile" > ~/.bash_profile
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
vim +PluginInstall +qall

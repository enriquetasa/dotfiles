cp /tasa_utilities/bashrc ~/.bashrc
cp /tasa_utilities/screenrc ~/.screenrc
cp /tasa_utilities/vimrc ~/.vimrc
cp /tasa_utilities/cgdbrc ~/.cgdb/
sh /tasa_utilities/nts_setup.sh
cp /tasa_utilities/ignore ~/.ignore
cp /tasa_utilities/bash_profile ~/.bash_profile
if [ ! -d ~/.vim/bundle/ ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi


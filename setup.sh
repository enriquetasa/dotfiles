cp /tasa_utilities/FilesToCopy/bashrc ~/.bashrc
cp /tasa_utilities/FilesToCopy/screenrc ~/.screenrc
cp /tasa_utilities/FilesToCopy/vimrc ~/.vimrc
cp /tasa_utilities/FilesToCopy/cgdbrc ~/.cgdb/
cp /tasa_utilities/FilesToCopy/ignore ~/.ignore
cp /tasa_utilities/FilesToCopy/bash_profile ~/.bash_profile
if [ ! -d ~/.vim/bundle/ ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
#sh /tasa_utilities/nts_setup.sh

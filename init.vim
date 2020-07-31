if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif

"Specify a directory for plugins
call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdtree'
Plug 'tsony-tsonev/nerdtree-git-plugin'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'
Plug 'airblade/vim-gitgutter'
Plug 'ctrlpvim/ctrlp.vim' " fuzzy find files
Plug 'scrooloose/nerdcommenter'
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }

Plug 'christoomey/vim-tmux-navigator'

Plug 'morhetz/gruvbox'

" Initialize plugin system
call plug#end()

" editor stuff
syntax enable
set shiftwidth=2
set softtabstop=2       " tabs equal 2 space 
set expandtab           " inserts spaces when tab is pressed
set showcmd             " show command in bottom bar
set smartindent         
set nostartofline
set smartcase
set display+=lastline
set wrap
set confirm
set backspace=indent,eol,start
set sm                  " matching braces
set pastetoggle=<F12>
set scrolloff=10
set textwidth=80

com! FormatJSON %!python -m json.tool


" Plugin stuff
filetype off " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'itchyny/lightline.vim'
Plugin 'junegunn/fzf'
Plugin 'valloric/youcompleteme'
Plugin 'joshdick/onedark.vim'

call vundle#end()            " required

" colours
syntax enable
set background=dark
set t_Co=256
set term=screen-256color
let g:onedark_termcolors=256
colorscheme onedark 

" editor stuff
set shiftwidth=2
set softtabstop=2       " tabs equal 2 space 
set expandtab           " inserts spaces when tab is pressed
set number              " show line numbers
set showcmd             " show command in bottom bar
set smartindent         
set nostartofline
set ignorecase
set smartcase
set display+=lastline
set wrap
set ruler
set confirm
set backspace=indent,eol,start
set bs=2
set wildmenu
set wildmode=longest,list
set cursorline
set showmatch
set nocompatible
set sm                  " matching braces
set pastetoggle=<F12>
set complete=.,w,b,u,t,]
set hlsearch
set incsearch
set laststatus=2
set scrolloff=10
set noai
set textwidth=80
set ttyfast

" remaps
nnoremap ; :
map <F1> :FZF<CR>

" Mistypes
:command W w
:command Bd bd
:command Wq wq
:command Q q
:command WQ wq

let g:lightline = {
  \ 'colorscheme': 'one',
  \ }

com! FormatJSON %!python -m json.tool


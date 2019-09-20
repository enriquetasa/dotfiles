" colours
syntax enable

" editor stuff
set softtabstop=2       " tabs equal 2 space 
set expandtab
set number              " show line numbers
set showcmd             " show command in bottom bar
set autoindent
set display+=lastline
set wrap
set ruler
set title
set confirm
set lazyredraw
set backspace=indent,eol,start
set wildmenu
set cursorline
set showmatch

" remaps
set pastetoggle=<F2>  " paste mode is triggered via F2
nnoremap ; :

" Mistypes
:command W w
:command Bd bd
:command Wq wq
:command Q q
:command WQ wq
:command q1 q!

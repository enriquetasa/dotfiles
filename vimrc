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

" DAI specific stuff """""""""""""""""""""""""""""""""""""""""""""""""

map <F8> :!ut_ctags<CR>
map! <F8> <ESC>:!ut_ctags<CR>
set tags=./tags,./TAGS,tags,TAGS,.tags,~/.tags,~/.TAGS

map <F9> :!ut_lib %<CR>
map! <F9> <ESC>:!ut_lib %<CR>
map <F10> :!ut_build %<CR>
map! <F10> <ESC>:!ut_build %<CR>
map <F11> :!ut_web<CR>
map! <F11> <ESC>:!ut_web<CR>

" Only do this part when compiled with support for autocommands.
"if has("autocmd")

  autocmd BufRead web_* map <F10> :!ut_lib % && ut_build web_om<CR>
  autocmd BufRead web_* map! <F10> <ESC>:!ut_lib % && ut_build web_om<CR>

  autocmd BufRead web_roi* map <F10> :!ut_lib % && ut_roi<CR>
  autocmd BufRead web_roi* map! <F10> <ESC>:!ut_lib % && ut_roi<CR>

  autocmd BufRead rdt* map <F10> :!ut_lib % && ut_build rdt_control<CR>
  autocmd BufRead rdt* map! <F10> <ESC>:!ut_lib % && ut_build rdt_control<CR>

  autocmd BufRead web_moi* map <F10> :!ut_lib % && ut_moi<CR>
  autocmd BufRead web_moi* map! <F10> <ESC>:!ut_lib % && ut_moi<CR>

"endif  has("autocmd")

map <C-F> :!grep -n <cword> *.c *.h > .vimfind<CR> :10sp .vimfind<CR> <C-W>r<CR>

:filetype plugin on

if has("autocmd")

  autocmd BufRead *.plugin set filetype=plugin
  autocmd BufRead sdf.txt set filetype=sdf

endif " has("autocmd")

" end DAI specific stuff """""""""""""""""""""""""""""""""""""

" colours
syntax enable
set background=dark
set t_Co=256
set term=screen-256color
let g:onedark_termcolors=256
colorscheme onedark 

" editor stuff
set shiftwidth=4
set softtabstop=4       " tabs equal 2 space 
set expandtab           " inserts spaces when tab is pressed
set number              " show line numbers
set showcmd             " show command in bottom bar
set smartindent         "
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


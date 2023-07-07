" install plug if it isn't installed
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif

" Specify a directory for plugins
call plug#begin('~/.config/nvim/plugged/')

" autocomplete
Plug 'davidhalter/jedi-vim'

" Syntax highlighting
set nocompatible
Plug 'sheerun/vim-polyglot'

" VIM visuals
" airline
Plug 'vim-airline/vim-airline' " airline status line
Plug 'vim-airline/vim-airline-themes'
let g:airline_theme = 'powerlineish'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1
let g:airline#extensions#virtualenv#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
" theme
Plug 'danilo-augusto/vim-afterglow'
let g:airline_theme='afterglow'

" Files and file trees
Plug 'scrooloose/nerdtree' " shows a file tree
Plug 'tpope/vim-fugitive' " git integration in file
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 50
" start nerdtree is we bring up vim without specifying a file
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

call plug#end()

" editor
" code
filetype plugin indent on
set shiftwidth=2        " indent width
set softtabstop=2       " tabs equal 2 space 
set expandtab           " inserts spaces when tab is pressed
set smartindent         " indent 'intelligently' 
" search
set ignorecase          " ignore and smart case help make search 
set smartcase           " non-case-sensitive unless you put caps in there
" display
syntax on
colorscheme afterglow
set showcmd             " show command in bottom bar
set number              " show line numbers
set showmatch           " match brackets with colours
set display+=lastline   " as much as possible of the last line will display
set backspace=indent,eol,start  " backspace works normally
set scrolloff=10        " displays 10 lines under scroll
set splitright          " display split files on the right by default
" saving
set confirm             " asks for confirmation when exiting
" folding
set nofoldenable        " do not display folded code on open
set foldmethod=indent   " fold methodology is by indentation
set foldnestmax=10
set foldlevel=2
" title stuff
set title
set titlestring=vim:\ %-25.55F\ %a%r%m titlelen=70

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" ctags
set tags=./tags;/
" Map Cmd+B to jump to the definition
nnoremap <D-b> <C-]>
" Map Cmd+LeftArrow to jump back
nnoremap <D-Left> <C-t>

" EDITOR CONFIGURATION

" code
filetype plugin indent on
set shiftwidth=2        " indent width
set softtabstop=2       " tabs equal 2 space 
set expandtab           " inserts spaces when tab is pressed
set smartindent         " indent 'intelligently'
set clipboard=unnamedplus "use systemclipboard when available

" search
set ignorecase          " ignore and smart case help make search 
set smartcase           " non-case-sensitive unless you put caps in there
set hlsearch            " highlight all search matches

" display
syntax on " syntax highlight
set nocompatible
colorscheme afterglow
set showcmd             " show command in bottom bar
set number              " show line numbers
set ruler               " show cursor position in line numbers
set showmatch           " match brackets with colours
set display+=lastline   " as much as possible of the last line will display
set backspace=indent,eol,start  " backspace works 'normally'
set scrolloff=10        " displays 10 lines under scroll
set splitright          " display split files on the right by default

" saving
set confirm             " asks for confirmation when exiting
set undofile            " persistundo history across sessions
set backup              " create backup files before overwriting
" create necessary directories if they don't exist
if empty(glob('~/.vim/{undo,backup,swap}'))
  silent mkdir ~/.vim/{undo,backup,swap} && chmod 700 -R ~/.vim 
  endif
set undodir=~/.vim/undo// 
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//

" folding
set nofoldenable        " do not display folded code on open
set foldmethod=indent   " fold methodology is by indentation
set foldnestmax=10
set foldlevel=2

" title 
set title
set titlestring=vim:\ %-25.55F\ %a%r%m titlelen=70

" END EDITOR CONFIGURATION "

" PLUGIN CONFIGURATION
" I currently use a plugin manager called 'plugged'
" install plug if it isn't installed
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim    
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif

" Specify a directory for plugins
call plug#begin()

" plugin: jedi (autocompleting)
Plug 'davidhalter/jedi-vim'

" plugin: polyglot (syntax highlighting)
Plug 'sheerun/vim-polyglot'

" plugin: airline (status line)
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

" plugin: afterglow (theme)
Plug 'danilo-augusto/vim-afterglow'
let g:airline_theme='afterglow'

" plugin: nerdtree (file tree)
Plug 'scrooloose/nerdtree' " shows a file tree
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 50
" start nerdtree if we bring up vim without specifying a file
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif


" plugin: fugitive (git integration)
Plug 'tpope/vim-fugitive' " git integration in file


" pluginS: blacK & iSort (python language tools)
Plug 'psf/black', { 'tag': '19.10b0' }
Plug 'fisadev/vim-isort'
" run isort and black on save
augroup black_on_save
  autocmd!
  autocmd BufWritePre *.py Black
  autocmd BufWritePre *.py Isort
augroup end

call plug#end() 

" END PLUGINS CONFIGURATION


" Allow saving of files as sudo when I forgot to start vim using sudo.
" by using ':w!!'
cmap w!! w !sudo tee > /dev/null %


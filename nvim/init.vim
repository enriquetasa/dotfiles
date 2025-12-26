" ==========================================
" 1. PLUGIN CONFIGURATION
" ==========================================

" Install vim-plug if not found
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Initialize Plugin System
call plug#begin('~/.config/nvim/plugged/')

" --- UI & Themes ---
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'danilo-augusto/vim-afterglow'
Plug 'scrooloose/nerdtree'

" --- Language Support & Syntax ---
Plug 'sheerun/vim-polyglot'  " Vast language support
Plug 'davidhalter/jedi-vim'  " Python autocompletion
Plug 'tpope/vim-fugitive'    " Git integration

" --- Fuzzy Finder & Grep ---
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" --- Python Tools ---
Plug 'psf/black', { 'tag': '19.10b0' }
Plug 'fisadev/vim-isort'

" --- Lua Plugins ---
" Note: these are Lua plugins, configured in section 2
Plug 'echasnovski/mini.pairs' 
Plug 'MagicDuck/grug-far.nvim'
Plug 'folke/which-key.nvim'

call plug#end()


" ==========================================
" 2. PLUGIN SPECIFIC SETTINGS
" ==========================================

" --- Airline ---
let g:airline_theme = 'afterglow'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1
let g:airline#extensions#virtualenv#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'

" --- NERDTree ---
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 50
let NERDTreeShowHidden=1

" Custom NERDTree Key Mappings
let g:NERDTreeMapActivateNode='a'  " Open dir/file with 'a'
let g:NERDTreeMapCloseDir='z'      " Close dir with 'z'

" Open NERDTree automatically if no file specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" Map Ctrl+N to toggle NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>

" --- FZF (Fuzzy Finder) ---
" This tells fzf to use the popup window
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

" --- Black & iSort (Python) ---
let g:python3_host_prog = '/opt/homebrew/bin/python3' 
augroup black_on_save
  autocmd!
  autocmd BufWritePre *.py Black
  autocmd BufWritePre *.py Isort
augroup end

" --- (Lua Config) ---
" Activates the lua plugins via embedded lua block
lua << EOF
require("mini.pairs").setup()
require('grug-far').setup();
require('folke/which-key.nvim').setup();
EOF


" ==========================================
" 3. EDITOR CONFIGURATION
" ==========================================

" --- Visuals ---
syntax on
set termguicolors     " Enable true colors
colorscheme afterglow " Set theme after plugins load

set number            " Show line numbers
set ruler             " Show cursor position
set showcmd           " Show command in bottom bar
set showmatch         " Highlight matching brackets
set display+=lastline " Show as much as possible of last line
set scrolloff=10      " Keep 10 lines of context when scrolling
set title             " Update terminal title
set titlestring=vim:\ %-25.55F\ %a%r%m

" --- Indentation ---
filetype plugin indent on
set shiftwidth=2      " Indent size
set softtabstop=2     " Tab key behavior
set expandtab         " Convert tabs to spaces
set smartindent       " Auto-indent new lines

" --- Search ---
set ignorecase        " Case insensitive search
set smartcase         " Case sensitive if capital used
set hlsearch          " Highlight matches

" --- System ---
set nocompatible
set clipboard=unnamedplus " Copy to system clipboard
set splitright            " Split new panes to right
set confirm               " Confirm before exiting unsaved
set backspace=indent,eol,start

" --- Backup & Undo Management ---
" Create directories if they don't exist to prevent errors
if !isdirectory(expand("~/.config/nvim/code/undo"))
    call mkdir(expand("~/.config/nvim/code/undo"), "p")
endif
if !isdirectory(expand("~/.config/nvim/code/backup"))
    call mkdir(expand("~/.config/nvim/code/backup"), "p")
endif
if !isdirectory(expand("~/.config/nvim/code/swap"))
    call mkdir(expand("~/.config/nvim/code/swap"), "p")
endif

set undofile
set backup
set undodir=~/.config/nvim/code/undo//
set backupdir=~/.config/nvim/code/backup//
set directory=~/.config/nvim/code/swap//

" --- Folding ---
set nofoldenable      " Don't fold by default
set foldmethod=indent
set foldnestmax=10
set foldlevel=2


" ==========================================
" 4. KEY MAPPINGS
" ==========================================

" Leader key (mapped to Space)
let mapleader = " "

" --- FZF Mappings ---
" <Space>f = Find Files (fuzzy search filenames)
nnoremap <leader>f :Files<CR>
" <Space>g = Grep (search inside files)
nnoremap <leader>g :Rg<CR>
" <Space>b = Find Buffers (search open tabs)
nnoremap <leader>b :Buffers<CR>

" Sudo write hack
cmap w!! w !sudo tee > /dev/null %

" Navigation with CMD key (Mac specific)
nnoremap <D-Left> <C-t>
nnoremap <D-Right> <C-]>

" Intelligent vertical split abbreviation
cnoreabbrev <expr> v (getcmdtype() == ':' && getcmdline() ==# 'v') ? 'vs' : 'v'

if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif

"Specify a directory for plugins
call plug#begin('~/.config/nvim/plugged/')

Plug 'scrooloose/nerdtree' " shows a file tree
" TODO - gives an error Plug 'tsony-tsonev/nerdtree-git-plugin' " shows git status in nerdtree 
Plug 'tiagofumo/vim-nerdtree-syntax-highlight' " shows file icons on nerdtree
Plug 'airblade/vim-gitgutter' " shows git status in vim files
Plug 'junegunn/fzf' " fuzzy find files
Plug 'vim-airline/vim-airline' " airline status line
Plug 'vim-airline/vim-airline-themes' " airline themes
Plug 'tmhedberg/SimpylFold' " good python folding
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' } " simple autocomplete
"Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' } " adds tabnine to autocomplete

" Initialize plugin system
call plug#end()

" editor stuff
syntax enable
set number              " show line numbers
set showmatch           " match brackets with colours
set shiftwidth=2        " indent width
set softtabstop=2       " tabs equal 2 space 
set expandtab           " inserts spaces when tab is pressed
set showcmd             " show command in bottom bar
set smartindent         " indent 'intelligently' 
set ignorecase          " ignore and smart case help make search 
set smartcase           " non-case-sensitive unless you put caps in there
set display+=lastline   " as much as possible of the last line will display
set confirm             " asks for confirmation when exiting
set backspace=indent,eol,start  " backspace works normally
set pastetoggle=<F12>   " F12 is the paste toggle
set scrolloff=10        " displays 10 lines under scroll
set splitright          " display split files on the right by default

" highlight text after 80 characters
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/

" title stuff
"set title
"set titlestring=VIM:\ %-25.55F\ %a%r%m titlelen=70

" status line
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\

" key bindings
map <C-n> :NERDTreeToggle<CR> " open nerdtree with Ctrl+N
" TODO - fzf 

" commands
com! FormatJSON %!python -m json.tool

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

"" NerdTree configuration

" start nerdtree is we bring up vim without specifying a file
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 50
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite

" airline configuration

let g:airline_theme = 'powerlineish'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1
let g:airline#extensions#virtualenv#enabled = 1

" autocomplete options
let g:deoplete#enable_at_startup = 1

" folding options
let g:SimpylFold_docstring_preview = 1
let g:SimpylFold_fold_import = 0
let g:SimpylFold_fold_docstring = 0

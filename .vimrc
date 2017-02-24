syntax enable
set background=dark
colorscheme molokai

set tabstop=4                   " number of visual spaces per <Tab>
set softtabstop=4               " number of spaces per <Tab> when editing
set expandtab                   " pressing <Tab> inserts spaces
filetype indent plugin on       " load filetype-specific indent files

set number                      " show line numbers
set ruler                       " show cursor position on status bar
set whichwrap+=<,>,h,l,[,]      " wrap left/right to previous/next line
set backspace=indent,eol,start  " backspace normally
set cursorline                  " highlight current line

set confirm                     " prompt save dialogue on failed save command
set visualbell                  " on error, flash screen instead of beep
set showcmd                     " show last command in bottom right bar
set wildmenu                    " visual autocomplete for command menu

" set cmdheight=2                 " height of command bar

set autoread                    " reload when file is changed from the outside

set incsearch                   " search as characters are inserted
set hlsearch                    " highlight matches
set ignorecase                  " case insensitive search,
set smartcase                   " except when using capital characters

set foldenable                  " enable folding
set foldmethod=indent           " fold based on indent level
set foldlevelstart=10           " open most folds by default (0-99)
set foldnestmax=10              " maximum number of nested folds

set mouse=a                     " enable mouse use in all modes
set clipboard=unnamed           " copy to clipboard on MacVim and Windows GVim

" move vertically by visual line
nnoremap j gj
nnoremap k gk

" move to beginning/end of line
nnoremap B ^
nnoremap E $

" set jk to escape in insert mode
inoremap jk <esc>

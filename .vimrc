"
"setting localleader
let mapleader=";"
let localmapleader=";"

"added for vundle support

set nocompatible              " be iMproved, required
filetype off                  "required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
"plugins to be added here

" Git support for vim
Plugin 'tpope/vim-fugitive'

" Track the engine.
Plugin 'SirVer/ultisnips'

" Snippets are separated from the engine. Add this if you want them:
Plugin 'honza/vim-snippets'

"plugin to help edit xml and html documents Plugin 'othree/xml.vim'

"plugin vim org mode
"Plugin 'jceb/vim-orgmode'

"Plugin for repeat of non vim commands
Plugin 'tpope/vim-repeat'

"Plugin to help in dates
Plugin 'tpope/vim-speeddating'

"plugin for autocomplete help
"Plugin 'valloric/youcompleteme'

"Plugin for nerdcommenter
Plugin 'scrooloose/nerdcommenter'

"Plugin for surround
Plugin 'tpope/vim-surround'

"Plugin for syntax checkers
Plugin 'scrooloose/syntastic'

"Plugin for nerdtree
Plugin 'scrooloose/nerdtree'

"Plugin calendar to help vimorg
Plugin 'mattn/calendar-vim'

"Plugin for vim ledger .. trying out finance management
Plugin 'ledger/vim-ledger'

"Plugin for vimwiki
Plugin 'vimwiki/vimwiki'

"Plugin for ctlrp fuzzy finder
Plugin 'ctrlpvim/ctrlp.vim'

"Plugin for solarized vim
Plugin 'altercation/vim-colors-solarized'

"Plugin for status line
Plugin 'vim-airline/vim-airline'


call vundle#end()       "required
filetype plugin indent on   "required

"End of added for vundle support
set number
set tabstop =4
set expandtab
set shiftwidth =4
set autoindent
"set textwidth=66
"autocomplete pattern when searching
set incsearch
autocmd BufRead,BufNewFile *.txt,*.md,*.rst,*.latex,*.wiki setlocal textwidth=66
"set smartindent

set nocompatible
filetype plugin indent on
syntax enable

set background=dark
colorscheme solarized
"ultisnips trigger configs
" Trigger configuration. Do not use <tab> if you use
" https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-e>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetDirectories=["UltiSnips", "mysnippets"]

" Options for vim-ledger files help
"
" Reomves leger from youcompleteme as recommended by vim-ledger
if exists('g:ycm_filetype_blacklist')
    call extend(g:ycm_filetype_blacklist, { 'ledger': 1 })
endif
"added to catch the most potential problems in file
let g:ledger_extra_options = '--pedantic --explicit --check-payees'

"allows autocomplete and align in ledger files
"au FileType ledger inoremap <Tab> \ <C-r>=ledger#autocomplete_and_align()<CR>
au FileType ledger vnoremap <Tab> :LedgerAlign<CR>

let g:ledger_default_commodity = 'Ksh '

let g:ledger_commodity_before = 1
let g:ledger_align_at = 50

"options for vim org mode
let g:org_agenda_files = ['~/org/index.org','~/org/projects.org']

"options for syntastic as recommended on github
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

"some trial of folding fix
set foldlevelstart=99

"eclim and youcompleteme
let g:EclimCompletionMethod='omnifunc'

"added for vimthehardway
set relativenumber
set numberwidth=3
set showmatch
"mapping for cu to uppercase word
imap <leader><c-u> <esc>bveUea
nmap <leader><c-u> bveUe

"setting localleader
let mapleader=";"
let localmapleader=";"

"added for bash like completion
set wildmode=longest,list,full
set wildmenu

"enable editting and sourcing vimrc
nnoremap  <leader>ev :vsplit <C-r>=resolve(expand($MYVIMRC))<cr><cr>
nnoremap  <leader>sv :source $MYVIMRC<cr>

"enable editing of ledger file
nnoremap <leader>e$ :vsplit ~/documents/ledger/blackbook.ledger<cr>

"abbrev for commong things
iabbrev @@ yohanaizraeli@gmail.com
iabbrev @@s johnduli@yahoo.com
iabbrev desing design
iabbrev Desing Design
iabbrev funtion function

"mappings from learnvimscipt
"maps H to start of line
nnoremap H ^
"maps L to end of lin
nnoremap L $
"map for html specific formatting I want
autocmd FileType html,javascript,arduino setlocal tabstop=2 
autocmd FileType html,javascript,arduino setlocal shiftwidth=2
set spell

autocmd FileType python :iabbrev <buffer> iff if:<left>
autocmd FileType javascript :iabbrev <buffer> iff if ()<left>

"map tds in insert mode to current date
autocmd FileType vimwiki :iabbrev <expr> tds strftime("[%a %d %b %Y]")
"delete times in vimwiki todo list
autocmd FileType vimwiki vnoremap dt :s/\[\d\d:\d\d\s-\s\d\d:\d\d\]//g <Cr>
autocmd FileType vimwiki nnoremap dt :s/\[\d\d:\d\d\s-\s\d\d:\d\d\]//g <Cr>
autocmd FileType vimwiki nnoremap <leader>tl :let g:vimwiki_folding='list' <Cr> :edit <Cr>
autocmd FileType vimwiki nnoremap <leader>tn :let g:vimwiki_folding='expr' <Cr> :edit <Cr>

let g:vimwiki_list = [{},
            \ {"path":"~/todo"}]
let g:vimwiki_folding = 'expr'

"for airline plugin
set t_Co=256
set laststatus=2
let g:airline_powerline_fonts=1
let g:airline_section_z= '%3p%% %l:%c'
"TODO figure out org tasks and pelican additions
"
"Syntastic c checkers
let g:syntastic_cpp_checkers = ['avrgcc','gcc']

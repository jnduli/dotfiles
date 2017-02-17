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

" Track the engine.
Plugin 'SirVer/ultisnips'

" Snippets are separated from the engine. Add this if you want them:
Plugin 'honza/vim-snippets'

"plugin to help edit xml and html documents Plugin 'othree/xml.vim'

"plugin vim org mode
Plugin 'jceb/vim-orgmode'

"Plugin for repeat of non vim commands
Plugin 'tpope/vim-repeat'

"Plugin to help in dates
Plugin 'tpope/vim-speeddating'

"plugin for autocomplete help
Plugin 'valloric/youcompleteme'

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

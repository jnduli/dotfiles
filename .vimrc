" vim-plug settings ----------{{{
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-fugitive' " git support
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets' " Snippet support
Plug 'vimwiki/vimwiki' | Plug 'mattn/calendar-vim' " Calendar, Diary and wiki management
Plug 'w0rp/ale' " Linting support (syntax and semantics)
Plug 'scrooloose/nerdcommenter' " commenting support
Plug 'morhetz/gruvbox' "Gruvbox color scheme
Plug 'nlknguyen/papercolor-theme'
Plug 'junegunn/goyo.vim' | Plug 'junegunn/limelight.vim' " Distraction free writing
Plug 'ledger/vim-ledger' " ledger-cli support
Plug 'vim-airline/vim-airline' " Using airline for status line
Plug 'tpope/vim-surround' " Helps in surrounding text e.g. replace \" with '

" Need to confirm if these are really required
" Plugin 'tpope/vim-speeddating'
" Plugin 'posva/vim-vue' " Vue support
" Plugin 'junegunn/fzf.vim' " FZF finder

call plug#end()
" ----------}}}

" General options for most files ------{{{

" Required for vimwiki to work properly and other things
set nocompatible
filetype plugin indent on " enables both plugin and indents of files
syntax on

set number " show line number where cursor is
set relativenumber " other lines shown relative to current line
set numberwidth=2 " Minimum space set for line nos
set tabstop=4 " <Tab> = 4 spaces
set shiftwidth =4 " Kinda similar to tabstop
set expandtab " Repalce <Tab> with spaces when used.
set autoindent " Copies current indent to next line
set smartindent " Better indenting than autoindent e.g. line after {
set incsearch " Show matching search pattern as you type
set showmatch " Jump to matching bracket temporarily once typed
cabbr <expr> %% expand('%:p:h') " Expands %% to directory in command

" setting local leader and global leader
let mapleader=";"
let maplocalleader=","

" added for bash like completion
set wildmode=longest,list,full
set wildmenu
" ------}}}

" Options for document files------{{{ 
autocmd BufRead,BufNewFile *.txt,*.md,*.rst,*.tex,*.wiki setlocal textwidth=72
autocmd BufRead,BufNewFile *.txt,*.md,*.rst,*.tex,*.wiki setlocal spell spelllang=en_gb " enable spell check
"------}}}

" Configs for gruvbox colorscheme ------{{{
set termguicolors " allow true color so that gruvbox looks good
let g:gruvbox_italic=1
let g:gruvbox_contrast_light="hard" " can be soft, medium(default) or hard
colorscheme gruvbox
" ------}}}

" Ultisnips configurations ------{{{

" ultisnips trigger configs
" let g:UltiSnipsExpandTrigger="<c-e>" Default is <tab>
" let g:UltiSnipsJumpForwardTrigger="<c-b>" Default is <c-j>
" let g:UltiSnipsJumpBackwardTrigger="<c-z>" Default is <c-k>

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetDirectories=["UltiSnips", "mysnippets"]
let g:UltiSnipsSnippetsDir="~/.vim/mysnippets"

" ------}}}

"
"
"


" Ledger config options ----- {{{
" Options for vim-ledger files help
"
"added to catch the most potential problems in file
let g:ledger_extra_options = '--pedantic --explicit --check-payees'

"allows autocomplete and align in ledger files
"au FileType ledger inoremap <Tab> \ <C-r>=ledger#autocomplete_and_align()<CR>
au FileType ledger vnoremap <Tab> :LedgerAlign<CR>

let g:ledger_default_commodity = 'Ksh '

let g:ledger_commodity_before = 1
let g:ledger_align_at = 50
" }}}

" Editting of commonly used files -------- {{{
" enable editting and sourcing vimrc
nnoremap  <leader>ev :vsplit <C-r>=resolve(expand($MYVIMRC))<cr><cr>
nnoremap  <leader>sv :source $MYVIMRC<cr>

" enable editing of ledger file
nnoremap <leader>e$ :vsplit ~/documents/ledger/blackbook.ledger<cr>
" }}}

"abbrev for common things --------- {{{
iabbrev @@ yohanaizraeli@gmail.com
iabbrev @@s johnduli@yahoo.com
iabbrev desing design
iabbrev Desing Design
iabbrev funtion function
" }}}

" mappings from learnvimscipt
" ononremap
onoremap in[ :<c-u>normal! f[vi[<cr>
onoremap il[ :<c-u>normal! F[vi[<cr>
onoremap in@ :execute "normal! /@\r:nohlsearch\rhviw"<cr> 
nnoremap <leader>pb :execute "leftabove vsplit " . bufname("#") <cr>
" Setting default tab space for some files ----- {{{
"map for html specific formatting I want
augroup indent_2_spaces
    autocmd!
    autocmd FileType html,javascript,arduino,vue setlocal tabstop=2 
    autocmd FileType html,javascript,arduino,vue setlocal shiftwidth=2
augroup END
"}}}

" some programs if statements ---------- {{{
augroup ifs
    autocmd FileType python :iabbrev <buffer> iff if:<left>
    autocmd FileType javascript :iabbrev <buffer> iff if ()<left>
augroup END
" }}}

" Vimwiki configuration ----- {{{
" Speeddating suport for the dates I use in todo lists
" SpeedDatingFormat %i %d %b %Y
" map tds in insert mode to current date
augroup filetype_vimwiki
    autocmd!
    autocmd FileType vimwiki :iabbrev <expr> tds strftime("[%a %d %b %Y]")
    "delete times in vimwiki todo list
    autocmd FileType vimwiki vnoremap dt :s/\s\[\d\d:\d\d\s-\s\d\d:\d\d\]//g <Cr>
    autocmd FileType vimwiki nnoremap dt :s/\s\[\d\d:\d\d\s-\s\d\d:\d\d\]//g <Cr>
    autocmd FileType vimwiki setlocal foldmethod=indent
    " calling let g:vimwiki_folding does not reset these variables, so set
    " local has been used instead
    autocmd FileType vimwiki nnoremap <leader>tl :setlocal foldmethod=expr <Cr> :setlocal foldexpr=VimwikiFoldListLevel(v:lnum) <Cr> :setlocal foldtext=VimwikiFoldText() <Cr>
    autocmd FileType vimwiki nnoremap <leader>tn :setlocal foldmethod=expr <Cr> :setlocal foldexpr=VimwikiFoldLevel(v:lnum) <Cr> :setlocal foldtext=VimwikiFoldText() <Cr>
    autocmd FileType vimwiki nnoremap <leader>cp :call TodoPercentage() <Cr>
augroup END

let g:vimwiki_list = [{},
            \ {"path":"~/todo"}]

" setting this to list makes diary generation very very slow
let g:vimwiki_folding = 'custom'

"vimwiki % of tasks done in table
"formatting of table should be
"| 12 | 13 | 15 | % |
"the place with the % should be left blank and will be filled by
"the function
function! TodoPercentage()
    normal ^3wviw"py
    let total = str2float(getreg("p"))
    normal ^5wviw"py
    let achieved = str2float(getreg("p"))
    let percentage = (achieved / total) * 100
    let per = printf("%.2f", percentage)
    execute "normal! ^6wa ".per."\<esc>"
endfunction
" }}}

"airline configs ----- {{{
"for airline plugin
" set t_Co=256
set laststatus=2
let g:airline_powerline_fonts=1
let g:airline_section_z= '%3p%% %l:%c'
" set to dark / light to change this theme
let g:airline_solarized_bg='light'
" }}}

" Vimscript file settings ---------------------- {{{
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
    autocmd FileType vim setlocal foldlevelstart=0
augroup END
" }}}

" NerdCommenter OPtions ---------------------- {{{
augroup nerd_commenter
    " Add spaces after comment delimiters by default
    let g:NERDSpaceDelims = 1
    " Use compact syntax for prettified multi-line comments
    let g:NERDCompactSexyComs = 1
    " Allow commenting and inverting empty lines (useful when commenting a region)
    let g:NERDCommentEmptyLines = 1
    " Enable trimming of trailing whitespace when uncommenting
    let g:NERDTrimTrailingWhitespace = 1
augroup END
" }}}

" Distraction Free Writing methods and modes ---------------- {{{
function! s:goyo_enter()
  " silent !tmux set status off
  " silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  set noshowmode
  set noshowcmd
  set scrolloff=999
  Limelight
  " ...
endfunction

function! s:goyo_leave()
  " silent !tmux set status on
  " silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  set showmode
  set showcmd
  set scrolloff=5
  Limelight!
  " ...
endfunction

" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
" nnoremap <buffer> <leader>w :Goyo<cr>
" }}}
"

" Fix width of calendar in vertical mode ----{{{
let g:calendar_options='nornu'
" ----}}}
"


" Shortcuts to use ALE checkers
"----{{{
nmap <silent> <leader>aj :ALENext<cr>
nmap <silent> <leader>ak :ALEPrevious<cr>
"----}}}
"
packadd! matchit

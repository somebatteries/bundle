"-----------------------------------------------------------
" Example vimrc
"-----------------------------------------------------------
"-----------------------------------------------------------
" Enable pathogen so that plugins can be kept in bundles under
" one repository
"-----------------------------------------------------------
runtime bundle/pathogen/autoload/pathogen.vim
execute pathogen#infect()
call pathogen#helptags()

"-----------------------------------------------------------
" Display bar of possible matches during tab-completion
"-----------------------------------------------------------
set wildmenu

"Turn on curly brace/parenthesis level highlighting
let g:rainbow_active = 1

set incsearch
set hlsearch
set nocp
filetype off
syntax on
filetype plugin on

"hacky crap to make scrollbars etc toggleable
":set guioptions-=m  "remove menu bar
:set guioptions-=T  "remove toolbar
:set guioptions-=L  "remove right-hand scroll bar
:set guioptions-=r  "remove right-hand scroll bar

"-----------------------------------------------------------
" Set up auto commands
"-----------------------------------------------------------
if( !exists( "g:vimrc_loaded" ) )
    let g:vimrc_loaded = 1

    "-------------------------------------------------------
    " override = operator with clang formatter
    "-------------------------------------------------------
    autocmd FileType c,cpp,objc map <buffer> = <Plug>(operator-clang-format)

    "-------------------------------------------------------
    " Remove trailing whitespace before saving
    "-------------------------------------------------------
    autocmd BufWritePre {*.c,*.h,*.cpp,*.hpp,*.py,*.vim,*.m,*.bat,*.xml} call StripTrailingSpaces()

    "-------------------------------------------------------
    " Auto-disassemble
    "-------------------------------------------------------
    autocmd BufReadCmd {*.o} exe "sil doau BufReadPre ".fnameescape(expand("<amatch>"))|exe 'silent %!/opt/toolchain/linaro-aarch64-2020.09-gcc10.2-linux5.4/aarch64-linux-gnu/bin/objdump -d ' . fnameescape(expand( "<amatch>" ))|set ro|exe "sil doau BufReadPost ".fnameescape(expand("<amatch>"))

    "-------------------------------------------------------
    " Custom syntax files
    "-------------------------------------------------------
    augroup filetypedetect
    au BufRead,BufNewFile *.scb,*.scbv set filetype=scb
    au BufRead,BufNewFile make.inc set filetype=make
    augroup END 
endif

"-----------------------------------------------------------
" Set up tabs
"-----------------------------------------------------------
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4

"-----------------------------------------------------------
" use :R to print command to scratch window
"-----------------------------------------------------------
:command! -nargs=* -complete=shellcmd R new | setlocal buftype=nofile bufhidden=hide noswapfile | r !<args>

"-----------------------------------------------------------
" Shorten some long commands
"-----------------------------------------------------------
:command! -nargs=? OS OpenSession <args>
:command! -nargs=? SS SaveSession <args>

"-----------------------------------------------------------
" Open help window vertically with :Help (capital H)
"-----------------------------------------------------------
:command! -nargs=* -complete=help Help vertical belowright help <args>

"-----------------------------------------------------------
" Auto increment a column of numbers:
" Select the column in column mode, and use ctrl-A
" 0 -> 0
" 0 -> 1
" 0 -> 2
" 0 -> 3
"-----------------------------------------------------------
function! Incr()
  let a = line('.') - line("'<")
  let c = virtcol("'<")
  if a > 0
    execute 'normal! '.c.'|'.a."\<C-a>"
  endif
  normal `<
endfunction
vnoremap <C-a> :call Incr()<CR>

"-----------------------------------------------------------
" Git blame current line
"-----------------------------------------------------------
nnoremap <Leader>b :<C-u>call gitblame#echo()<CR>

"-----------------------------------------------------------
" Alt-j inserts a blank line below the current line.
" Alt-k inserts a blank line above the current line.
"-----------------------------------------------------------
nnoremap <silent>j :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent>k :set paste<CR>m`O<Esc>``:set nopaste<CR>

"-----------------------------------------------------------
" Quick sub : Allows a yanked value to not be un-yanked
" after you paste over something
"-----------------------------------------------------------
nnoremap S ciw<C-r>0<ESC>
vnoremap S "0P

"-----------------------------------------------------------
" Search only within selected lines ( use after selecting )
"-----------------------------------------------------------
vnoremap <M-/> <Esc>/\%V

"-----------------------------------------------------------
"Make the following actions 'undoable'
"-----------------------------------------------------------
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

map <leader>r :call FindReplace()<CR>

"-----------------------------------------------------------
" Toggle display of toolbars
"-----------------------------------------------------------
map <S-F1> <ESC>:if &go=~#'m'<Bar>set go-=m<Bar>else<Bar>set go+=m<Bar>endif<CR>

map <F2> :Tlist<CR>
"-----------------------------------------------------------
" View Requirements
"-----------------------------------------------------------
map <S-F5> <ESC>:silent !view_req.py D:\Requirements\DB\proj\gia6xw_mswrd\<C-R><C-W>.xml > vim_tmp_req<C-R><C-W>.txt<CR><ESC>:sview vim_tmp_req<C-R><C-W>.txt<CR><C-W>1_<CR>

"-----------------------------------------------------------
" Copy / Paste to clipboard, respectively
"-----------------------------------------------------------
map <F6> "*y
map <F7> "*p
map <F8> :call GRM_comment()<CR>


"-----------------------------------------------------------
" Execute current file
"-----------------------------------------------------------
map <F11> :!%<CR>

"-----------------------------------------------------------
" Show current file in explorer
"-----------------------------------------------------------
"map <S-F12> :execute "!start explorer /select,\"" . expand( "%:p" ) . "\""<CR>
map [24;2~ :silent execute "!xfce4-terminal --working-directory=\"" . expand("%:p:h") . "\""<CR>:redraw!<CR>

"-----------------------------------------------------------
" Use <leader>8 to bring up pep8 errors
"-----------------------------------------------------------
let g:pep8_map='<leader>8'

"-----------------------------------------------------------
" Edit the module test relating to the current file
"-----------------------------------------------------------
map <leader>et :call EditTest()<CR>

"-----------------------------------------------------------
" Buffer movement
"-----------------------------------------------------------
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

"-----------------------------------------------------------
" Use ctrl-space for ctrl-n ( autocomplete )
"-----------------------------------------------------------
inoremap <C-Space> <C-n>

"-----------------------------------------------------------
" Use CTRL-N, CTRL-P to cyle through grep results
"-----------------------------------------------------------
nmap <silent> <C-N> :cn<CR>zv
nmap <silent> <C-P> :cp<CR>zv

"-----------------------------------------------------------
" Use CTRL-S for saving, also in Insert mode
"-----------------------------------------------------------
noremap <C-S> :update<CR>
vnoremap <C-S> <C-C>:update<CR>
inoremap <C-S> <ESC>:update<CR>

"-----------------------------------------------------------
" Grep for word under cursor, no prompting
"-----------------------------------------------------------
map <C-F> :call GrepPrompt(2)<CR>

"-----------------------------------------------------------
" Grep keys
"-----------------------------------------------------------
map [13~ :call GrepPrompt(1)<CR>
map <F3> :call GrepPrompt(1)<CR>
map ^[OR :call GrepPrompt(1)<CR>

map [25~ : call GrepPrompt(0)<CR>
map <S-F3> :call GrepPrompt(0)<CR>
map O1;2R :call GrepPrompt(0)<CR>
map [1;2R :call GrepPrompt(0)<CR>

map [14~ :call GrepCurrentFile(1)<CR>
map <F4> :call GrepCurrentFile(1)<CR>
map OS :call GrepCurrentFile(1)<CR>

map <S-F4> :call GrepCurrentFile(0)<CR>
map [26~ :call GrepCurrentFile(0)<CR>
map O1;2S :call GrepCurrentFile(0)<CR>
map [1;2S :call GrepCurrentFile(0)<CR>


"-----------------------------------------------------------
" View Requirements
"-----------------------------------------------------------
map <S-F5> <ESC>:silent !view_req.py D:\Requirements\DB\proj\gia6xw_mswrd\<C-R><C-W>.xml > vim_tmp_req<C-R><C-W>.txt<CR><ESC>:sview vim_tmp_req<C-R><C-W>.txt<CR><C-W>1_<CR>
map <F8> :call GrmComment()<CR>
"If an ftags file is found, use the tags file to find the file, otherwise, recursively search for a file
nnoremap <expr> <f9> filereadable('./ftags') ? ':call ProjFiles()<CR>' : ':e **/*'

"-----------------------------------------------------------
" Grm_format
"-----------------------------------------------------------
nmap <script> <silent> <Leader>f mKHmL`K:call GRM_Format_struct()<CR>`Lzt`K
nmap <script> <silent> <Leader>a mKHmL`K:call GRM_align_col()<CR>`Lzt`K
vmap <script> <silent> <Leader>a <ESC>mKHmL`K:call GRM_align_col()<CR>
nmap <script> <silent> <Leader><F8> :call GRM_append_comment()<CR>

"-----------------------------------------------------------
" Locate on HSDB
"-----------------------------------------------------------
nmap <script> <silent> <Leader>h :call GRM_locate_hsdb_pkt()<CR><CR>:botright cw<CR>

"-----------------------------------------------------------
" Make right-/left-shifts keep selection
"-----------------------------------------------------------
vnoremap > ><CR>gv
vnoremap < <<CR>gv

"-----------------------------------------------------------
" Change vertical buffer width by pressing Alt+Shift+>
" or Alt+Shift+<        ( Not the arrow keys )
"-----------------------------------------------------------
nmap > :vertical res +10<CR>
nmap < :vertical res -10<CR>

"-----------------------------------------------------------
" Comment out selected lines using your initials
"-----------------------------------------------------------
map <leader>k :call GrmCodeRvwComment(1, 1)<CR>
map <leader>u :call GrmCodeRvwComment(0, 1)<CR>

"-----------------------------------------------------------
" Comment out selected lines without using your initials
"-----------------------------------------------------------
map <leader>cc :call GrmCodeRvwComment(1, 0)<CR>
map <leader>cu :call GrmCodeRvwComment(0, 0)<CR>

"-----------------------------------------------------------
" Open command prompt at directory of current file
"-----------------------------------------------------------
map <F12> :call OpenCMDPrompt()<CR>
function! OpenCMDPrompt()
    "execute "silent ! start /D \"" . expand( '%:p:h' ) . "\" cmd"
    :silent execute "!xfce4-terminal --working-directory=\"" . expand("%:p:h") . "\""
    redraw!
endfunction

"-----------------------------------------------------------
" Bubble single and multiple lines
"-----------------------------------------------------------
nmap <C-Up> ddkP
nmap <C-Down> ddp
vmap <C-Up> xkP`[V`]
vmap <C-Down> xp`[V`]

map <C-[> :tag <C-R><C-W><CR>

"-----------------------------------------------------------
" Toggle spell checking on and off with `,s`
"-----------------------------------------------------------
nmap <silent> ,s :set spell!<CR> 
set spelllang=en

"-----------------------------------------------------------
" Key         - <cp>
" Description - Copy current file path to clipboard 
"               (without file name)
"-----------------------------------------------------------
nmap cp :let @0 = expand("%:p:h")<CR>

"-----------------------------------------------------------
" Key         - <cf>
" Description - Copy current file name to clipboard 
"-----------------------------------------------------------
nmap cf :let @0 = expand("%:t")<CR>

"-----------------------------------------------------------
" Used for having the function name in the status bar
"-----------------------------------------------------------
set updatetime=250
"autocmd CursorHold {*.[c]*} call SetFuncName()
"autocmd CursorHold {*.[^h]*} let g:function_name = GetTagName(line("."))

"-----------------------------------------------------------
" Key         - <leader>l
" Description - Show git log ( allows user to modify the directory )
"-----------------------------------------------------------
"map <leader>l :silent !start "C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe" /command:log /path:<C-r>=expand("%:p:h")<CR>
"map <leader>l :silent execute "!gitk \"" . expand("%:p:h") . "\"&"<CR>:redraw!<CR>
map <leader>l :silent execute "!xfce4-terminal --geometry 0x0 --working-directory=\"" . expand("%:p:h") . "\" -x gitk"<CR>:redraw!<CR>

"-----------------------------------------------------------
" Status bar customization
"-----------------------------------------------------------
set laststatus=2                         " always display status bar
set statusline=%f                        " full filename
"set statusline+=%t                      " tail of the filename
"set statusline+=[%{strlen(&fenc)?&fenc:'none'}, " file encoding
"set statusline+=%{&ff}]                 " file format
"set statusline+=%h                      " help file flag
set statusline+=%m                       " modified flag
set statusline+=%r                       " read only flag
"set statusline+=%y                      " filetype
set statusline+=\ %1*%{g:project_name}%* " Project name ( highlighted )
set statusline+=\ %1*%{g:function_name}%* " Project name ( highlighted )
set statusline+=%=                       " left/right separator
set statusline+=%c,                      " cursor column
set statusline+=%l/%L                    " cursor line/total lines
set statusline+=\ %P                     " percent through file

"-----------------------------------------------------------
" Align at =
"-----------------------------------------------------------
map <leader>= :Tabularize /\(for(.*\\|=\\|[<>!]\\|".*\)\@<![-+*&\/\|]\?=\(=\)\@!<CR>

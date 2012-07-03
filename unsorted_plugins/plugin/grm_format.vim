"----------------------------------------------------------
" C-Indent settings
"----------------------------------------------------------
set nowrap
set noautoindent
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set cin
set cinoptions+={1s
set cinoptions=>s,e0,n0,fs,{s,}0,^-s,:s,=s,l0,gs,hs,ps,ts,+s,c3,C0,(2s,us,U0,w0,m0,j0,)20,*30
set nobackup
set nowritebackup
set comments=


"----------------------------------------------------------
" Function Definitions
"----------------------------------------------------------

"-----------------------------------------------------------
" Function    - Mark()
" Description - Mark the current position
"-----------------------------------------------------------
" No recommended Configuration
"-----------------------------------------------------------
function! Mark()
    let s:mark = line(".") . "G" . virtcol(".") . "|"
    normal! H
    let s:mark = "normal!" . line(".") . "Gzt" . s:mark
    execute s:mark
    return s:mark
endfunction

"-----------------------------------------------------------
" Function    - StripTrailingSpaces()
" Description - Removes trailing spaces from the file.
"-----------------------------------------------------------
" Recommended Configuration
"-----------------------------------------------------------
" autocmd BufWritePre {*.c,*.h,*.cpp,*.hpp,*.py,*.vim} call StripTrailingSpaces()
"-----------------------------------------------------------
function! StripTrailingSpaces()
    if &expandtab != ""
        let s:currPos=Mark()
        "execute "normal mZ"
        exec 'v:^--\s*$:s:\s\+$::e'
        "execute "normal `Z"
        exe s:currPos
        exec ":retab"
    endif
endfunction

"-----------------------------------------------------------
" Function    - CodeRvwComment()
" Description - Insert code review comment
"-----------------------------------------------------------
" Recommended Configuration
"-----------------------------------------------------------
"
"-----------------------------------------------------------
:function! CodeRvwComment()
:   let s:ftype = expand("%:e")
:    if s:ftype == "c" || s:ftype == "h" || s:ftype == "cpp"
:        exe "normal O\<ESC>0i//codervw:" . $me_id . " - "
:    elseif s:ftype == "s" || s:ftype == "inc" || s:ftype == "asm"
:        exe "normal O\<ESC>0i;;codervw:" . $me_id . " - "
:    elseif s:ftype == "py" || s:ftype == "pl" || s:ftype == "pm" || s:ftype == "mak"
:        exe "normal O\<ESC>0i##codervw:" . $me_id . " - "
:    else
:        return
:    endif
:endf

"-----------------------------------------------------------
" Function    - GRM_append_comment()
" Description - Append a comment
"-----------------------------------------------------------
function! GRM_append_comment()
    let orig_txt=getline(".")
    let last_line_modified = line(".")

    if( match( orig_txt, '\/\*.*\*\/' ) >= 0 )
        "---------------------------------------------------
        " Grab the comment
        "---------------------------------------------------
        let dflt_comment = matchstr( orig_txt, '\(\/\*\)\s*\zs.\{-}\ze\s*\(\*\/\)' )

        "---------------------------------------------------
        " Erase the comment from the original text
        "---------------------------------------------------
        let orig_txt = matchstr( orig_txt, '\zs.\{-}\ze\s*\/\*.*\*\/' )
    else
        let dflt_comment = ""
    endif

    "-------------------------------------------------------
    " Keep looking for the multiline comment
    "-------------------------------------------------------
    let i=1
    let next_line=getline(line(".")+i)
    while( match( next_line, '^\s*\/\*.*\*\/\s*$' ) >= 0  )

        "---------------------------------------------------
        " Grab the comment
        "---------------------------------------------------
        let comment = matchstr( next_line, '\(\/\*\)\s*\zs.\{-}\ze\s*\(\*\/\)' )
        let last_line_modified = line(".")+i
        if( dflt_comment != "" )
            let dflt_comment = dflt_comment . " " . comment
        else
            let dflt_comment = comment
        endif

        let i=i+1
        let next_line=getline(line(".")+i)
    endwhile

    let comment = input( "Comment: ", dflt_comment )
    if( comment != "" )
        exe ":" .  line(".") . "," . last_line_modified . "delete"
        exe "normal k0"
        exe ":read\ !python\ \"" . s:grm_fmt_tool_path . "\" -c \"append_comment\" -o\ " . shellescape(orig_txt,1) . " -t\ " . shellescape(comment,1)
    endif
endfunction

"-----------------------------------------------------------
" Function    - GRM_align_col()
" Description - Use K-means clustering to align columns
"-----------------------------------------------------------
" Recommended Configuration
"-----------------------------------------------------------
"
"-----------------------------------------------------------
function! GRM_align_col()
    let text_before = "c:\\temp\\text_before.txt"
    let text_after = "c:\\temp\\text_after.txt"

    "Write selection to a file
    exe "'<,'>w! " . text_before

    "Delete the original text
    normal "vgvdk"

    let k = input( "Number of columns? ( leave blank for Auto ): " )
    if( k < 1 )
        exe ":silent :read\ !python\ \"" . s:align_col_tool_path . "\" -f\ \"" . text_before . "\""
    else
        exe ":silent :read\ !python\ \"" . s:align_col_tool_path . "\" -f\ \"" . text_before . "\" -k " . k
    endif

endfunction


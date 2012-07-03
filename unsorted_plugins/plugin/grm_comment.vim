"-----------------------------------------------------------
" Grm style of block commenting
" Creates block comment from the current indent to column
" 60.  Works for c, java, perl, python, and assembly files.
"
" Use the F8 key to insert a comment around the current
" line or currently selected group of lines.
"
" written by Travis Meili
"-----------------------------------------------------------

"-----------------------------------------------------------
" Suggested Key mapping
"-----------------------------------------------------------
"map <F8> :call GrmComment()<CR>
autocmd filetypedetect BufEnter,BufNewFile * call SetCommentCharacters()

function! SetCommentCharacters()
    let s:single_line_comment_char_close = ""

    if( match( &filetype, '\<\(c\|cpp\|dts\|java\|php\)\>' ) >= 0 )
        let s:single_line_comment_char_start = "//"
    elseif( match( &filetype, '\(python\|perl\|scb\|conf\|jam\|sh\)' ) >= 0 )
        let s:single_line_comment_char_start = "#"
    elseif( match( &filetype, 'asm' ) >= 0 )
        let s:single_line_comment_char_start = ";"
    elseif( match( &filetype, 'vim' ) >= 0 )
        let s:single_line_comment_char_start = "\""
    elseif( match( &filetype, 'matlab' ) >= 0 )
        let s:single_line_comment_char_start = "%"
    elseif( match( &filetype, 'dosbatch' ) >= 0 )
        let s:single_line_comment_char_start = "::"
    elseif( match( &filetype, 'xml' ) >= 0 )
        let s:single_line_comment_char_start = "<!--"
        let s:single_line_comment_char_close = " -->"
    else
        let s:single_line_comment_char_start = ""
    endif
endf

function! GrmComment() range
    let l:indent = indent( a:firstline )
    let l:ind = ""
    let l:i = l:indent
    let l:fill = ""
    let l:use_multiline_comment = 0

    if( match( &filetype, '\<\(c\|cpp\|java\)\>' ) >= 0 )
        let l:beginning = "/*"
        let l:ending = "*/"
        let l:middle = ""
        let l:fillChar = "-"
        let l:use_multiline_comment = 1
    elseif( match( &filetype, '\<\(xml\)\>' ) >= 0 )
        let l:beginning = "<!--"
        let l:ending = "-->"
        let l:middle = ""
        let l:fillChar = "="
        let l:use_multiline_comment = 1
    elseif( s:single_line_comment_char_start != "" )
        let l:beginning = s:single_line_comment_char_start . "-"
        let l:ending = "--"
        let l:middle = s:single_line_comment_char_start . " "
        let l:fillChar = "-"
    else
        return
    endif

    while( l:i > 0 )
        let l:ind = l:ind . " "
        let l:i = l:i - 1
    endwhile

    let l:i = l:indent

    while( l:i < 58 )
        let l:fill = l:fill . l:fillChar
        let l:i = l:i + 1
    endwhile

    call append( a:firstline - 1, l:ind . l:beginning . l:fill )
    let l:curLine = a:firstline + 1

    while( l:curLine <= a:lastline + 1 )
        let l:text = getline( l:curLine )
        let l:line_ind = indent( l:curLine ) - strlen( l:ind )
        let l:i = l:line_ind
        let l:line_ind = ""

        while( l:i > 0 )
            let l:line_ind = l:line_ind . " "
            let l:i = l:i - 1
        endwhile

        let l:text = substitute( l:text, '^\s*', l:ind . l:middle . l:line_ind, "g" )
        call setline( l:curLine, l:text )
        let l:curLine = l:curLine + 1
    endwhile

    if( l:use_multiline_comment )
        call append( a:lastline + 1, l:ind . l:fill . l:ending )
    else
        call append( a:lastline + 1, l:ind . l:beginning . l:fill )
    endif
endfunction

"-----------------------------------------------------------
" Function    - CommentLine()
" Description - Comment out a line.
"-----------------------------------------------------------
function! CommentLine( add ) range
    exe a:firstline . "," . a:lastline . 'call GrmCodeRvwComment( a:add, 0 )'
endf

"-----------------------------------------------------------
" Function    - GrmCodeRvwComment()
" Description - Comment/Uncomment a range of lines with the
" option to insert the users initials
"-----------------------------------------------------------
function! GrmCodeRvwComment( add_not_remove, write_initials ) range
    "-----------------------------------------------------------
    " Determine what the comment character is based on file type
    "-----------------------------------------------------------
    if( s:single_line_comment_char_start != "" )
        let l:fillChar = s:single_line_comment_char_start
    else
        return
    endif

    let l:closingChar = s:single_line_comment_char_close

    "-----------------------------------------------------------
    " Add initials
    "-----------------------------------------------------------
    if( a:write_initials )
        let l:fillChar = l:fillChar . $me_id . " "
    endif

    "-----------------------------------------------------------
    " Loop through selected lines and make/remove comment
    "-----------------------------------------------------------
    for l:curLine in range( a:firstline, a:lastline )
        let l:text = getline( l:curLine )

        if( a:add_not_remove )
            let l:text = l:fillChar . l:text . l:closingChar
        else
            let l:text = substitute( l:text, l:fillChar, "", "" )
            let l:text = substitute( l:text, l:closingChar . "$", "", "" )
        endif

        call setline( l:curLine, l:text )
    endfor
endfunction

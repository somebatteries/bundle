"-----------------------------------------------------------
" File: proj_cmd.vim
" Author: Garrett Smith ( garrett.smith@garmin.com )
"
" Description: This file provides a command to quickly open a project
"-----------------------------------------------------------

let g:PROJ_file  = $HOME . '/.vim/bundle/grm_project/proj_file'

" Configuration variables {{{

" Maximum number of entries allowed in the MRU list
if !exists('PROJ_Max_Entries')
    let PROJ_Max_Entries = 100
endif

" Height of the PROJ window
" Default height is 8
if !exists('PROJ_Window_Height')
    let PROJ_Window_Height = 8
endif

if !exists('PROJ_Use_Current_Window')
    let PROJ_Use_Current_Window = 0
endif

if !exists('PROJ_Auto_Close')
    let PROJ_Auto_Close = 1
endif

" When opening a file from the PROJ list, the file is opened in the current
" tab. If the selected file has to be opened in a tab always, then set the
" following variable to 1. If the file is already opened in a tab, then the
" cursor will be moved to that tab.
if !exists('PROJ_Open_File_Use_Tabs')
    let PROJ_Open_File_Use_Tabs = 0
endif

"}}}

" Public Interface {{{

" Command to open the PROJ window
command! -nargs=? -complete=customlist,s:PROJ_Complete PROJ
            \ call s:PROJ_Cmd(<q-args>)
command! -nargs=? -complete=customlist,s:PROJ_Complete Proj
            \ call s:PROJ_Cmd(<q-args>)

" PROJ_Add_Entry {{{
" Function which is called by the :Proj command
function! PROJ_Add_Entry( proj_name, root_dir )

    let a:root_dir = simplify( a:root_dir )
    for i in range( len( s:PROJ_names ) )
        if( ( s:PROJ_names[i] == a:proj_name ) && ( s:PROJ_paths[i] == a:root_dir  ) )
            " The project was already added
            return
        endif
    endfor

    "-------------------------------------------------------
    " If they weren't in the list before, add them
    "-------------------------------------------------------
    call insert( s:PROJ_names, a:proj_name, 0 )
    call insert( s:PROJ_paths, a:root_dir, 0 )

    "-------------------------------------------------------
    " Trim the list if it gets too big
    "-------------------------------------------------------
    if( len( s:PROJ_names ) > g:PROJ_Max_Entries )
        echomsg "Removing projects"
        call remove( s:PROJ_names, g:PROJ_Max_Entries, -1 )
        call remove( s:PROJ_paths, g:PROJ_Max_Entries, -1 )
    endif

    "-------------------------------------------------------
    " Write to the file
    "-------------------------------------------------------
    let out_buf = []
    for i in range( len( s:PROJ_names ) )
        call add( out_buf, "<NAME=" . s:PROJ_names[i] . "> <PATH=" . s:PROJ_paths[i] . ">" )
    endfor
    call writefile( out_buf, g:PROJ_file )

endfunction
"}}}
"}}}
" Private functions {{{
" PROJ_Cmd {{{
" Function which is called by the :Proj command
function! s:PROJ_Cmd(pat)
    "---------------------------------------------------------
    " Load the recent projects
    "---------------------------------------------------------
    call s:PROJ_Load( g:PROJ_file )

    "-------------------------------------------------------
    " Show the window
    "-------------------------------------------------------
    " Save the current buffer number. This is used later to open a file when a
    " entry is selected from the PROJ window. The window number is not saved,
    " as the window number will change when new windows are opened.
    let s:PROJ_last_buffer = bufnr('%')
    call s:PROJ_DisplayBuffer( a:pat, s:PROJ_names, s:PROJ_paths )
endfunction
"}}}
" MRU_Warn_Msg                          {{{
" Display a warning message
function! s:PROJ_Warn_Msg(msg)
    echohl WarningMsg
    echo a:msg
    echohl None
endfunction
"}}}
" PROJ_Open_Window    {{{
" Function to display the actual buffer
function! s:PROJ_Open_Window(...)

    " Save the current buffer number. This is used later to open a file when a
    " entry is selected from the PROJ window. The window number is not saved,
    " as the window number will change when new windows are opened.
    let s:PROJ_last_buffer = bufnr('%')

    let bname = '__PROJ_Files__'

    " If the window is already open, jump to it
    let winnum = bufwinnr(bname)
    if winnum != -1
        if winnr() != winnum
            " If not already in the window, jump to it
            exe winnum . 'wincmd w'
        endif

        setlocal modifiable

        " Delete the contents of the buffer to the black-hole register
        silent! %delete _
    else
        if g:PROJ_Use_Current_Window
            " Reuse the current window
            "
            " If the __PROJ_Files__ buffer exists, then reuse it. Otherwise open
            " a new buffer
            let bufnum = bufnr(bname)
            if bufnum == -1
                let cmd = 'edit ' . bname
            else
                let cmd = 'buffer ' . bufnum
            endif

            exe cmd

            if bufnr('%') != bufnr(bname)
                " Failed to edit the PROJ buffer
                return
            endif
        else
            " Open a new window at the bottom

            " If the __PROJ_Files__ buffer exists, then reuse it. Otherwise open
            " a new buffer
            let bufnum = bufnr(bname)
            if bufnum == -1
                let wcmd = bname
            else
                let wcmd = '+buffer' . bufnum
            endif

            exe 'silent! botright ' . g:PROJ_Window_Height . 'split ' . wcmd
        endif
    endif

    " Mark the buffer as scratch
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    setlocal nowrap
    setlocal nobuflisted
    " Use fixed height for the PROJ window
    setlocal winfixheight

    " Setup syntax highlighting
    call s:PROJ_SetupSyntax()

    " Setup the cpoptions properly for the maps to work
    let old_cpoptions = &cpoptions
    set cpoptions&vim

    " Create mappings to select and edit a file from the PROJ list
    nnoremap <buffer> <silent> <CR>
                \ :call <SID>PROJ_Select_File_Cmd('edit,useopen')<CR>
    vnoremap <buffer> <silent> <CR>
                \ :call <SID>PROJ_Select_File_Cmd('edit,useopen')<CR>
    nnoremap <buffer> <silent> s
                \ :call <SID>PROJ_Select_File_Cmd('edit,newwin_horiz')<CR>
    vnoremap <buffer> <silent> s
                \ :call <SID>PROJ_Select_File_Cmd('edit,newwin_horiz')<CR>
    nnoremap <buffer> <silent> v
                \ :call <SID>PROJ_Select_File_Cmd('edit,newwin_vert')<CR>
    vnoremap <buffer> <silent> v
                \ :call <SID>PROJ_Select_File_Cmd('edit,newwin_vert')<CR>
    nnoremap <buffer> <silent> u :PROJ<CR>
    nnoremap <buffer> <silent> <2-LeftMouse>
                \ :call <SID>PROJ_Select_File_Cmd('edit,useopen')<CR>
    nnoremap <buffer> <silent> q :close<CR>

    " Restore the previous cpoptions settings
    let &cpoptions = old_cpoptions

endfunction
"}}}

" MRU_Select_File_Cmd                   {{{
" Open a file selected from the MRU window
"
"   'opt' has two values separated by comma. The first value specifies how to
"   edit the file  and can be either 'edit' or 'view'. The second value
"   specifies where to open the file. It can take one of the following values:
"     'useopen' to open file in the previous window
"     'newwin_horiz' to open the file in a new horizontal split window
"     'newwin_vert' to open the file in a new vertical split window.
"     'newtab' to open the file in a new tab.
" If multiple file names are selected using visual mode, then open multiple
" files (either in split windows or tabs)
function! s:PROJ_Select_File_Cmd(opt) range
    if( ( a:firstline == 1 ) && ( a:lastline == 1 ) )
        "---------------------------------------------------
        " Disallow selection of the headers which is on line 1
        "---------------------------------------------------
        normal j
        return
    elseif( a:firstline == 1 )
        let a:firstline = 2
    endif

    let [edit_type, open_type] = split(a:opt, ',')

    let fnames = []
    for line in getline(a:firstline, a:lastline)
        "---------------------------------------------------
        " Get the second column for the path
        "---------------------------------------------------
        call add( fnames, matchstr( line, '''\zs.*\ze''' ) )
    endfor

    if g:PROJ_Auto_Close == 1 && g:PROJ_Use_Current_Window == 0
        " Automatically close the window if the file window is
        " not used to display the PROJ list.
        silent! close
    endif

    let multi = 0

    for file in fnames
        if file == ''
            continue
        endif

        call s:PROJ_Window_Edit_File(file, multi, edit_type, open_type)

        if a:firstline != a:lastline
            " Opening multiple files
            let multi = 1
        endif
    endfor
endfunction
"}}}

" PROJ_escape_filename                   {{{
" Escape special characters in a filename. Special characters in file names
" that should be escaped (for security reasons)
let s:esc_filename_chars = ' *?[{`$%#"|!<>();&' . "'\t\n"
function! s:PROJ_escape_filename(fname)
    return escape(a:fname, s:esc_filename_chars)
endfunction
"}}}
"
" PROJ_Window_Edit_File                  {{{
"   fname     : Name of the file to edit. May specify single or multiple
"               files.
"   edit_type : Specifies how to edit the file. Can be one of 'edit' or 'view'.
"               'view' - Open the file as a read-only file
"               'edit' - Edit the file as a regular file
"   multi     : Specifies  whether a single file or multiple files need to be
"               opened.
"   open_type : Specifies where to open the file. Can be one of 'useopen' or
"               'newwin' or 'newtab'.
"               useopen - If the file is already present in a window, then
"                         jump to that window.  Otherwise, open the file in
"                         the previous window.
"               newwin_horiz - Open the file in a new horizontal window.
"               newwin_vert - Open the file in a new vertical window.
"               newtab  - Open the file in a new tab. If the file is already
"                         opened in a tab, then jump to that tab.
function! s:PROJ_Window_Edit_File(fname, multi, edit_type, open_type)
    let esc_fname = s:PROJ_escape_filename(a:fname)

    if a:open_type == 'newwin_horiz'
        " Edit the file in a new horizontally split window above the previous
        " window
        wincmd p
        exe 'belowright new ' . esc_fname
    elseif a:open_type == 'newwin_vert'
        " Edit the file in a new vertically split window above the previous
        " window
        wincmd p
        exe 'belowright vnew ' . esc_fname
    elseif a:open_type == 'newtab' || g:PROJ_Open_File_Use_Tabs
    call s:PROJ_Open_File_In_Tab(a:fname, esc_fname)
    else
        " If the selected file is already open in one of the windows,
        " jump to it
        let winnum = bufwinnr('^' . a:fname . '$')
        if winnum != -1
            exe winnum . 'wincmd w'
        else
            if g:PROJ_Auto_Close == 1 && g:PROJ_Use_Current_Window == 0
                " Jump to the window from which the PROJ window was opened
                if exists('s:PROJ_last_buffer')
                    let last_winnr = bufwinnr(s:PROJ_last_buffer)
                    if last_winnr != -1 && last_winnr != winnr()
                        exe last_winnr . 'wincmd w'
                    endif
                endif
            else
                if g:PROJ_Use_Current_Window == 0
                    " Goto the previous window
                    " If PROJ_Use_Current_Window is set to one, then the
                    " current window is used to open the file
                    wincmd p
                endif
            endif

            let split_window = 0

            if &modified || &previewwindow || a:multi
                " Current buffer has unsaved changes or is the preview window
                " or the user is opening multiple files
                " So open the file in a new window
                let split_window = 1
            endif

            if &filetype != 'netrw'
                if &buftype != ''
                    " Current buffer is a special buffer (maybe used by a plugin)
                    if g:PROJ_Use_Current_Window == 0 ||
                                \ bufnr('%') != bufnr('__PROJ_Files__')
                        let split_window = 1
                    endif
                endif
            endif

            " Edit the file
            if split_window
                " Current buffer has unsaved changes or is a special buffer or
                " is the preview window.  So open the file in a new window
                if a:edit_type == 'edit'
                    exe 'split ' . esc_fname
                else
                    exe 'sview ' . esc_fname
                endif
            else
                if a:edit_type == 'edit'
                    exe 'edit ' . esc_fname
                else
                    exe 'view ' . esc_fname
                endif
            endif
        endif
    endif
endfunction
"}}}

"PROJ_Load {{{
" Used to get the projects from the project-file
function! s:PROJ_Load( filename )

    let s:PROJ_names = []
    let s:PROJ_paths = []
    "-------------------------------------------------------
    " strip out into columns
    "-------------------------------------------------------
    if filereadable(g:PROJ_file)
        for line in readfile(g:PROJ_file)
            call add( s:PROJ_names, matchstr( line, '<NAME=\zs.\{-}\ze>' ) )
            call add( s:PROJ_paths, matchstr( line, '<PATH=\zs.\{-}\ze>' ) )
        endfor
    else
        "---------------------------------------------------
        " Supply the user with some defaults if it fails.
        " The defaults will be saved to the file when created.
        "---------------------------------------------------
        call s:PROJ_Warn_Msg('Unable to read ' . g:PROJ_file . ". Creating file" )
        call PROJ_Add_Entry( 'GIAW', 'd:\giaw\dev' )
    endif
endfunction
"}}}
"PROJ_DisplayBuffer         {{{
" Function to display the actual buffer window
function! s:PROJ_DisplayBuffer( filtr_expr, names, paths )

    " Check for empty PROJ list
    if empty( a:paths ) || empty( a:names )
        call s:PROJ_Warn_Msg('PROJ file list is empty')
        return
    endif

    if len(a:paths) != len( a:names )
        call s:PROJ_Warn_Msg('Array lengths not equal!')
        return
    endif

    "---------------------------------------------------
    " Only display those that match the filter,
    " and sort them based upon which ones are from
    " the known projects
    "---------------------------------------------------
    let matches = []
    for i in range( len( a:names ) )
        if( ( a:filtr_expr == '' ) || ( match( a:names[i], a:filtr_expr ) >= 0 ) )
            call add( matches, a:names[i] . "   '" . a:paths[i] ."'")
            let quick_open_file = a:paths[i]
        endif
    endfor

    if( len( matches ) == 1 )
        "---------------------------------------------------
        " Go straight to the project
        "---------------------------------------------------
        call s:PROJ_Window_Edit_File(quick_open_file, 0, 'edit', 'useopen')
    else
        "-------------------------------------------------------
        " Display and select the buffer only if there are
        " multiple matches
        "-------------------------------------------------------
        call s:PROJ_Open_Window()
        silent! 0put = 'Project    ''Directory'''
        silent! put = matches

        " Delete the empty line at the end of the buffer
        $delete

        " Align the table
"        exe ':%Tab /\S\+$/l4'
        exe ":%Tabularize /'.*'$/l4"

        " Move the cursor to the beginning of the file
        normal! ggj

        setlocal nomodifiable
    endif
endfunction
"}}}

" PROJ_SetupSyntax {{{
function! s:PROJ_SetupSyntax()
  if has("syntax")
    syn match PROJ_Heading "^Project\s*'Directory'"

    hi def link PROJ_Heading String
  endif
endfunction
"}}}
" Command Helper functions                       {{{

" Works like sort(), optionally taking in a comparator (just like the
" original), except that duplicate entries will be removed.
" Credit to Salman Halim
function! SortUnique( list, ... )
    let dictionary = {}
    for i in a:list
        execute "let dictionary[ '" . i . "' ] = ''"
    endfor
    let result = []
    if ( exists( 'a:1' ) )
        let result = sort( keys( dictionary ), a:1 )
    else
        let result = sort( keys( dictionary ) )
    endif
    return result
endfunction

" Command-line completion function used by :PROJ command
function! s:PROJ_Complete(ArgLead, CmdLine, CursorPos)
    if a:ArgLead == ''
        " Return the complete list of PROJ files
        return SortUnique( s:PROJ_names )
    else
        " Return only the files matching the specified pattern
        return SortUnique( filter(copy(s:PROJ_names) , 'v:val =~? a:ArgLead') )
    endif
endfunction

"}}}
"}}}

" Load the PROJ list on plugin startup
call s:PROJ_Load( g:PROJ_file )
" vim:ft=vim foldmethod=marker sw=4

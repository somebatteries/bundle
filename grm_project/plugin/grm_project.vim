"-----------------------------------------------------------
" File: grm_project.vim
" Author: Garrett Smith ( garrett.smith@garmin.com )
"
" This file provides functions for auto-sourcing projects when
" entering a recognized garmin project directory, and quickly
" opening files contained within a project.  It also specifies
" the default behavior for how to build ctags.
"-----------------------------------------------------------
"-----------------------------------------------------------
" Suggested Key mapping
"-----------------------------------------------------------
"map <f9> :call ProjFiles()<CR>
let g:files_without_functions = {}
let g:files_without_classes = {}

function! FindFunctionsPresent()
    "-----------------------------------------------------------
    " This will search the file when it is loaded for functions.
    " If they aren't in the file, it disables function searching
    "-----------------------------------------------------------
    let save_cursor = getpos(".")
    call setpos('.', [0, 0, 0, 0] )
    let filename = expand( "%" )
    if( strlen( filename ) )
        let g:files_without_functions[ filename ] = 0
        let g:files_without_classes[ filename ] = 0
        if( match( &filetype, '\<\(c\|cpp\|java\)\>' ) >= 0 )
            let pattern='\(\*\s*PROCEDURE NAME.*\n\*\s*\)\@<=\(\w\+\)'
            let str = getline(search(pattern, 'Wn', 5000 ) )
            if( !strlen(str) )
                let g:files_without_functions[ filename ] = 1
                return
            endif
        elseif( match( &filetype, 'python' ) >= 0 )
            let pattern='\(^\s*def\s\+\)\@<=\(\w\+\)'
            let str = getline(search(pattern, 'Wn', 5000))
            if( !strlen(str) )
                let g:files_without_functions[ filename ] = 1
            else
                let pattern = '\(^\s*class\s\+\)\@<=\(\w\+\)'
                let str = getline(search(pattern, 'Wn', 5000))
                if( !strlen(str) )
                    let g:files_without_classes[ filename ] = 1
                endif
            endif
        elseif( match( &filetype, 'vim' ) >= 0 )
            let pattern = '\(^:\?fun\w*!\?\s\+\)\@<=\(\(s\:\)\?\w\+\)'
            let str = getline(search(pattern, 'Wn', 5000))
            if( !strlen(str) )
                let g:files_without_functions[ filename ] = 1
            endif
        endif
    endif
    call setpos('.', save_cursor)
endf

let g:function_name=""
function! SetFuncName()
"    TODO: implement some line number caching: i.e. only perform the search if the line number jumped outside the known range
    let filename = expand( "%" )
    if( !strlen( filename ) || get( g:files_without_functions, filename ) )
        let g:function_name = "FcnSearchDisbld"
        return
    endif

    let g:function_name=""
    if( match( &filetype, 'vim' ) >= 0 )
        let pattern = '\(^:\?fun\w*!\?\s\+\)\@<=\(\(s\:\)\?\w\+\)'
        let str = getline(search(pattern, 'bWn',max( [ 0, line(".")-1000] )))
        if( !strlen(str) )
            let g:files_without_functions[ filename ] = 1
            let g:function_name = "FcnSearchDisbld"
            return
        endif
        let g:function_name = matchstr( str, pattern )
    else
        exe "YcmCompleter GetParent"
    endif
endfunc

"-----------------------------------------------------------
" Set up default project grep parameters
"-----------------------------------------------------------

function! BuildCTagsDefault()
    let s:ftype = expand("%:e")
    if &filetype == "python"
         exe "silent !tmux new -d \"ctags -R -B --langmap=python:+.pyw --python-kinds=-i  --extra=+fq\""
"        !ctags -B --langmap=python:+.pyw --python-kinds=-i  --extra=+fq
    elseif s:ftype == "c" || s:ftype == "h" || s:ftype == "cpp" || s:ftype == "hpp" || &filetype == "netrw"
        exe "Dispatch! find . -path ./out -prune -o -regex '.*\\.[chS]' | tee ftags.txt | ctags -B --c++-kinds=-p+l --fields=+iaS --extra=+fq -I _compiler_assert+ -I compiler_assert+ -L - && grep '\\bF$' tags > ftags"
    else
        echom "Don't know how to build ctags for this file"
    endif
endfunction

"-----------------------------------------------------------
" Assign default build ctags function to default behavior
"-----------------------------------------------------------
function! BuildCTags()
    call BuildCTagsDefault()
endfunction

function! ProjFiles()
    "-----------------------------------------------------------
    " Save off old tags file
    "-----------------------------------------------------------
    let l:cur_tags=&tags
    set tags=ftags
    let filename = input(":tag ","*","tag")
    if filename != ""
        "---------------------------------------------------
        " Search through the file tags for a file
        "---------------------------------------------------
        execute ":tag ". filename
    endif
    "-----------------------------------------------------------
    " Restore old tags file
    "-----------------------------------------------------------
    let &tags = l:cur_tags
endfunction

function! UseDefaultProject()
    source ~/.vim/bundle/default_project.vim
endf

function! FindProjectVimFile()
    "-------------------------------------------------------
    " Walk backwards until project.vim is found
    "-------------------------------------------------------
    let s:search_folder=expand("%:p:h")
    let s:project_vim_path=""
    while s:search_folder != ""
        if( filereadable( s:search_folder . "/project.vim" ) )
            let s:project_vim_path =  s:search_folder
            break
        elseif s:search_folder == "/"
            let s:search_folder = ""
        else
            let s:search_folder = simplify( s:search_folder. "/../" )
        endif
    endw
    return s:project_vim_path
endf

function! SourceProject()
    "-----------------------------------------------------------
    " Each project can specify its project name, for display
    " in the status_bar
    "-----------------------------------------------------------
    let g:project_name = "Dflt"
    let g:project_constant_cwd = 0

    "-----------------------------------------------------------
    " Determine project directory
    "-----------------------------------------------------------
    let s:current_file_path=expand("%:p:h")
    let s:current_file_path = substitute( tolower( s:current_file_path ), "\\\\", "/", "g" )

    "-----------------------------------------------------------
    " Check if we are in a subfolder of a project
    "-----------------------------------------------------------
    let g:project_vim_path = FindProjectVimFile()

    "-----------------------------------------------------------
    " Project specific scripts
    "-----------------------------------------------------------
    if( ( g:project_vim_path != "" ) && filereadable( g:project_vim_path . "/project.vim" ) )
        try
            "-----------------------------------------------------------
            " If the project.vim did not specify a name, then use ?
            "-----------------------------------------------------------
            let g:project_name = "?"

            exe "source " . g:project_vim_path . "/project.vim"

            "---------------------------------------------------
            " Register this project in the PROJ_file
            "---------------------------------------------------
            call PROJ_Add_Entry( g:project_name, g:project_vim_path )

            if( exists( "g:vimrc_loaded" ) )
                "echo "sourced " . g:project_vim_path . "/project.vim"
            endif
        catch
            if( exists( "g:vimrc_loaded" ) )
                "echo "unable to source: ". g:project_vim_path . "/project.vim"
            endif
        endtry
    else
        "---------------------------------------------------
        " Setup default project
        "---------------------------------------------------
        call UseDefaultProject()
    endif

    "-------------------------------------------------------
    " Retain constant working directory
    "-------------------------------------------------------
    if( g:project_constant_cwd )
        exec "cd " . g:project_vim_path
    endif

endfunction

call SourceProject()

if( !exists( "g:grm_project_loaded" ) )
    let g:grm_project_loaded = 1

    "-----------------------------------------------------------
    " Try to load the project for any file opened
    "-----------------------------------------------------------
    autocmd BufEnter,BufNewFile * call SourceProject()
    autocmd BufRead * call FindFunctionsPresent()
endif

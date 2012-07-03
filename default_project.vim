"-----------------------------------------------------------
" This is the default project.vim which will be sourced
" if no project.vim is able to be sourced
"-----------------------------------------------------------
let g:project_name = "Dflt"
let g:project_constant_cwd = 0
set tags=tags

let g:grepScope = "R"
let g:grepRootRecursiveDir = "" "Use the directory of the current file
let g:grepExcludeDirs = ".git"
set makeprg=make

"-------------------------------------------------------
" Default filetype when grepping
"-------------------------------------------------------
if &filetype == "python"
    let g:grepDfltFileTypes = "*.py"
elseif &filetype == "vim"
    let g:grepDfltFileTypes = "*.vim"
elseif &filetype == "matlab"
    let g:grepDfltFileTypes = "*.m"
elseif &filetype == "make"
    let g:grepDfltFileTypes = "Makefile* *.mk *.inc"
else
    let g:grepDfltFileTypes = "*.c *.h *.cpp *.hpp"
endif

"-------------------------------------------------------
" Define CTags behavior
"-------------------------------------------------------
function! BuildCTags()
    call BuildCTagsDefault()
endfunction

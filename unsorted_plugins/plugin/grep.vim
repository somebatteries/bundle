func! GitGrep(...)
    call system("git rev-parse")
    let save = &grepprg
    if( !v:shell_error )
        set grepprg=git\ grep\ -P\ -n\ --recurse-submodules\ $*
    endif
    let s = 'silent grep!'
    for i in a:000
        let s = s . ' ' . i
    endfor
    exe s
    let &grepprg = save

    "-------------------------------------------------------
    " Highlight search results
    "-------------------------------------------------------
    let @/ = '\v' . a:000[0]
    exe ":silent set hlsearch"

    "-------------------------------------------------------
    " Show search list
    "-------------------------------------------------------
    execute ":botright copen"
    redraw!
endfun
command! -nargs=? G call GitGrep(<f-args>)


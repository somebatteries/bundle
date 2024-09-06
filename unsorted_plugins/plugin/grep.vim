function! AsyncGrep(...)
  :compiler grep
  execute 'Make ' . join(a:000, ' ')
  "-------------------------------------------------------
  " Highlight search results
  "-------------------------------------------------------
  let @/ = '\v' . a:000[0]
  exe ":silent set hlsearch"
endfunction
command! -nargs=+ -complete=file_in_path G call AsyncGrep(<f-args>)

func! Grep(...)
    :compiler grep
    execute 'make ' . join(a:000, ' ')

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
command! -nargs=+ -complete=file_in_path GNow call Grep(<f-args>)

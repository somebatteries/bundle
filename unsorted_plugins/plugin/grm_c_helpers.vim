
function! FindAllModifications()
    let keys = "/\\(.*memcpy([ ]*[&]*\<C-R>\<C-W>[ ]*,.*\\|\<C-R>\<C-W>[^A-Za-z_0-9=!><]*=[^=]\\|.*memset([ ]*[&]*\<C-R>\<C-W>[ ]*,.*\\|[^&]&[^,&]*\<C-R>\<C-W>\\)\<CR>"
    "let keys = "\<S-F3>(memcpy\\([ ]*[&]*\<C-R>\<C-W>[ ]*,|\<C-R>\<C-W>[^A-Za-z_0-9=!><]*=[^=]|memset\\([ ]*[&]*\<C-R>\<C-W>[ ]*,|[^&]&[^,&]*\<C-R>\<C-W>)"
    call feedkeys(keys)
endfunction






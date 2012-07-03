"-----------------------------------------------------------
" Module Testing functionality
" Allows the running of module tests from inside Vim, as
" well as the editing of the mod test relating to the current
" file.
"
" Use leader t to open a vertical split pane editing the mod
" test.
"
" written by Seth Lienemann
"-----------------------------------------------------------
" Command to open the mod test
command! -nargs=* Test call s:ModTest(<q-args>)

"*********************************************************************
"
"   PROCEDURE NAME:
"       ModTest - Start up the module test for the current file
"
"   DESCRIPTION:
"       Start up the module test for the current file, also include
"       the user's command line flags
"
"********************************************************************
function! s:ModTest( ... )
  let cur_dir = getcwd()
  let file_root = fnamemodify( bufname( winbufnr( winnr() ) ), ":t:r" )

  let arg_val = ""
  " Append the args we've been passed
  for arg in a:000
      let arg_val .= " " . arg
  endfor

  " We're already in the mod test directory
  if( file_root =~ "_test" )
      exe "silent :! start /b run_test.py " . arg_val . " --np"
      echo file_root
  else
      let fname = file_root . '_test'
      echo fname
      set suffixesadd=.py,.c,.cpp
      let test_file = findfile( fname, "**" )
      if( test_file != "" )
          let test_dir = fnamemodify( test_file, ":h" )
          exe ":lcd " . test_dir

          exe "silent :! start /b run_test.py " . arg_val . " --np"
      else
          echo "A test with the name " . fname . " doesn't exist!"
      endif
  endif
  exe ":lcd " . cur_dir
endfunction

"*********************************************************************
"
"   PROCEDURE NAME:
"       EditTest - Edit the module test in a split window
"
"   DESCRIPTION:
"       Edit the module test in a split window
"
"   TODO: Update the function to look if the user has that buffer open
"   already, and use that buffer instead of opening a new one
"
"********************************************************************

"-----------------------------------------------------------
" Suggested key mapping
"-----------------------------------------------------------
"map <leader>et :call EditTest()
function! EditTest()
    let cur_file = bufname( winbufnr( winnr() ) )
    let cur_dir  = getcwd()

    if( cur_file !~ ".*_test\.[py\|c\|cpp]" )
        " We're in the .c file, looking for the test
        let fname = fnamemodify( cur_file, ":t:r" ) . '_test'
        set suffixesadd=.py,.c,.cpp

        let test_file = findfile( fname, "**" )
        if( test_file != "" )
            call s:openFile( test_file, cur_dir )
            return
        else
            echo "Test " . fname . " not found!"
        endif

    else
        " We're in the test file, looking for the FUT
        let cur_file = substitute( cur_file, "_test.*", "", "" )
        exe ":cd " . fnamemodify( cur_file, ":p:h" )
        let fname = fnamemodify( cur_file, ":t:r" )
        set suffixesadd=.c

        if( !filereadable( fname . "_test.vcproj" ) )
            echo "Are you sure you're in a module test?"
            return
        endif

        let vcproj_file = readfile( fname . "_test.vcproj" )
        for line in vcproj_file
            let search_pat = "RelativePath.*" . fname . ".c"
            if( line =~ search_pat )
                let file_path = substitute( line, '.*RelativePath=', "", "" )
                let file_path = substitute( file_path, '"', '', "g" )
                " Make sure that we've actually gotten the path we're looking
                " for
                if( file_path != line )
                    call s:openFile( file_path, cur_dir )
                    return
                endif
            endif
        endfor
        echo "Couldn't find a test for " . fname . ".c"
    endif

endfunction

function! s:openFile( file_path, cwd )
    let full_path = fnamemodify( a:file_path, ":p" )
    let winnum = bufwinnr( full_path )
    "if the window is already loaded, go to it
    if( winnum != -1 )
        if( winnum != winnr() )
            exe ":cd " . a:cwd
            exe winnum . 'wincmd w'
        endif
    " otherwise, just open a new split
    else
        exe ":cd " . a:cwd
        exe ":vs " . full_path
    endif
endfunction

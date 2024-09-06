let current_compiler = 'grep'
call system("git rev-parse")
if( !v:shell_error )
    CompilerSet makeprg=git\ --no-pager\ grep\ -P\ -n\ --recurse-submodules
    "echom "git found, using git grep"
else
    CompilerSet makeprg=grep\ -P\ -n
    "echom "git not found, falling back to grep"
endif
CompilerSet errorformat=%f:%l:%m

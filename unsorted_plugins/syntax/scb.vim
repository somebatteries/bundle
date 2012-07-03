" Vim syntax file
" Language: scb
" Maintainer:
" Last Change:

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

set syntax=conf

highlight link scb_region_header    Title
highlight link scb_variable         Number
highlight link scb_keyword          Constant
highlight link scb_variable_declare Function

syn match scb_region_header     /<\w\+>/
syn match Keyword               /&\w\+&/
syn match scb_variable          /\$\w\+\$/
syn match scb_variable_declare  /\$\w\+\s/



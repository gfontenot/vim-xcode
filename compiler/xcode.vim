if exists('current_compiler')
    finish
endif
let current_compiler = 'xcode'

" vint: -ProhibitAbbreviationOption
let s:save_cpo = &cpo
set cpo&vim
" vint: +ProhibitAbbreviationOption

if exists(':CompilerSet') != 2
    command -nargs=* CompilerSet setlocal <args>
endif

if !exists('g:xcode_compiler_cmd') || g:xcode_compiler_cmd ==? ''
    Xcompiler
endif

call setbufvar(bufnr('%'), '&makeprg', g:xcode_compiler_cmd)

CompilerSet errorformat=
            \%f:%l:%c:\ %trror:\ %m,
            \%f:%l:%c:\ %tarning:\ %m,
            \%trror:\ %m\ at\ %l:%c\ in\ %f.,
            \[x]\ %trror:\ %m\ at\ %l:%c\ in\ %f.,
            \❌\ %trror:\ %m\ at\ %l:%c\ in\ %f.,
            \[!]\ %tarning:\ %m\ at\ %l:%c\ in\ %f.,
            \⚠️\ %tarning:\ %m\ at\ %l:%c\ in\ %f.,
            \%E[x]\ %f:%l:%c:\ %m,
            \%E❌\ %f:%l:%c:\ %m,
            \%W[!]\ %f:%l:%c:\ %m,
            \%W⚠️\ %f:%l:%c:\ %m,
            \%E%>\ \ %[a-zA-Z]%#\\,\ failed\ \-\ %m,%Z\ \ %f:%l

" vint: -ProhibitAbbreviationOption
let &cpo = s:save_cpo
unlet s:save_cpo
" vint: +ProhibitAbbreviationOption

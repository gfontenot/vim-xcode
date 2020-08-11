if exists("current_compiler")
    finish
endif
let current_compiler = "swiftc"

" vint: -ProhibitAbbreviationOption
let s:save_cpo = &cpo
set cpo&vim
" vint: +ProhibitAbbreviationOption

if exists(":CompilerSet") != 2
    command -nargs=* CompilerSet setlocal <args>
endif

if !exists('g:xcode_compiler_cmd') || g:xcode_compiler_cmd ==? ''
    Xcompiler
endif

call setbufvar(bufnr('%'), '&makeprg', g:xcode_compiler_cmd)

CompilerSet errorformat=
            \[x]\ %trror:\ %m\ at\ %l:%c\ in\ %f.,
            \[x]\ %f:%l:%c:\ %m,
            \[!]\ %f:%l:%c:\ %m

" vint: -ProhibitAbbreviationOption
let &cpo = s:save_cpo
unlet s:save_cpo
" vint: +ProhibitAbbreviationOption

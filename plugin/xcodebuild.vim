command! XcodebuildBuild call <sid>build()
command! XcodebuildTest call <sid>test()

let s:plugin_path = expand("<sfile>:p:h:h")

if !exists("g:xcpretty_testing_flags")
  let g:xcpretty_testing_flags = ""
endif

if !exists("g:xcpretty_flags")
  let g:xcpretty_flags = "--color"
endif

function! s:build()
  let cmd = s:base_command()  . s:xcpretty()
  call s:run_command(cmd)
endfunction

function! s:test()
  let cmd =  s:base_command() . ' -sdk iphonesimulator test' . s:xcpretty_test()
  call s:run_command(cmd)
endfunction

function! s:run_command(cmd)
  execute '!' . a:cmd
endfunction

function! s:base_command()
  return 'xcodebuild ' . s:build_target() . ' ' . s:scheme()
endfunction

function! s:build_target()
  let xcworkspaceFile = glob('*.xcworkspace')
  if empty(xcworkspaceFile)
    return '-project ' . s:project_file()
  else
    return '-workspace ' . xcworkspaceFile
  endif
endfunction

function! s:project_file()
  return globpath(expand('.'), '*.xcodeproj')
endfunction

function! s:scheme()
  let scheme = system("source " . s:plugin_path . "/bin/find_scheme.sh \"" . s:project_file() . "\"")
  return '-scheme '. scheme
endfunction

function! s:xcpretty()
  if executable('xcpretty')
    return ' | xcpretty ' . g:xcpretty_flags
  else
    return ''
  endif
endfunction

function! s:xcpretty_test()
  let xcpretty = s:xcpretty()
  if empty(xcpretty)
    return ''
  endif

  return xcpretty . ' ' . g:xcpretty_testing_flags
endfunction

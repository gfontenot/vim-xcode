command! XBuild call <sid>build()
command! XTest call <sid>test()

let s:plugin_path = expand('<sfile>:p:h:h')

function! s:bin_script(name)
  return s:plugin_path . '/bin/' . a:name
endfunction

function! s:cli_args(...)
  let cli_args = ''

  for cli_arg in a:000
    let cli_args = cli_args . ' ' . shellescape(cli_arg)
  endfor

  return cli_args
endfunction

function! s:build()
  let cmd = s:base_command()  . s:xcpretty()
  call s:run_command(cmd)
endfunction

function! s:test()
  let cmd =  s:base_command() . ' ' . s:sdk() . ' test' . s:xcpretty_test()
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
  return '-scheme '. s:scheme_name()
endfunction

function!s:scheme_name()
  if !exists('s:chosen_scheme')
    let s:chosen_scheme = system('source ' . s:bin_script('find_scheme.sh') . s:cli_args(s:project_file()))
  endif

  return s:chosen_scheme
endfunction

function! s:sdk()
  if !exists('s:use_simulator')
    call system('source ' . s:bin_script('use_simulator.sh') . s:cli_args(s:project_file(), s:scheme_name()))
    let s:use_simulator = !v:shell_error
  endif

  if s:use_simulator
    return '-sdk iphonesimulator'
  else
    return '-sdk macosx'
  endif
endfunction

function! s:xcpretty()
  if executable('xcpretty')
    return ' | xcpretty ' . s:xcpretty_flags()
  else
    return ''
  endif
endfunction

function! s:xcpretty_test()
  let xcpretty = s:xcpretty()
  if empty(xcpretty)
    return ''
  else
    return xcpretty . ' ' . s:xcpretty_testing_flags()
  endif
endfunction

function! s:xcpretty_flags()
  if exists('g:xcodebuild_xcpretty_flags')
    return g:xcodebuild_xcpretty_flags
  else
    return '--color'
  endif
endfunction

function! s:xcpretty_testing_flags()
  if exists('g:xcodebuild_xcpretty_testing_flags')
    return g:xcodebuild_xcpretty_testing_flags
  else
    return ''
  endif
endfunction

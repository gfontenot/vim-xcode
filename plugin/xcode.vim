command! XBuild call <sid>build()
command! XTest call <sid>test()
command! XClean call <sid>clean()
command! -nargs=? -complete=file XOpen call <sid>open("<args>")
command! -nargs=1 -complete=file XSwitch call <sid>switch("<args>")
command! -nargs=1 -complete=file XSelectProject call <sid>set_project("<args>")
command! -nargs=1 XSelectScheme call <sid>set_scheme("<args>")

let s:default_run_command = '! {cmd}'
let s:default_xcpretty_flags = '--color'
let s:default_xcpretty_testing_flags = ''

let s:plugin_path = expand('<sfile>:p:h:h')

function! s:bin_script(name)
  return s:plugin_path . '/bin/' . a:name
endfunction

function! s:cli_args(...)
  return ' ' . join(map(copy(a:000), 'shellescape(v:val)'))
endfunction

function! s:build()
  if s:assert_project()
    let cmd = s:base_command() . ' ' . s:destination() . s:xcpretty()
    call s:run_command(cmd)
  endif
endfunction

function! s:test()
  if s:assert_project()
    let cmd =  s:base_command() . ' ' . s:destination() . ' test' . s:xcpretty_test()
    call s:run_command(cmd)
  endif
endfunction

function! s:clean()
  if s:assert_project()
    let cmd = s:base_command() . ' clean' . s:xcpretty()
    call s:run_command(cmd)
  endif
endfunction

function! s:open(path)
  if s:assert_project()
    if empty(a:path)
      let file_path = "."
    else
      let file_path = a:path
    endif
    call system('source ' . s:bin_script('open_project.sh') . s:cli_args(file_path))
  endif
endfunction

function! s:switch(target)
  execute '!sudo xcode-select -s' . s:cli_args(a:target)
endfunction

function! s:set_project(project)
  let s:chosen_project = a:project
  unlet! s:chosen_scheme
  unlet! s:use_simulator
endfunction

function! s:set_scheme(scheme)
  let s:chosen_scheme = a:scheme
  unlet! s:use_simulator
endfunction

function! s:run_command(cmd)
  let run_cmd = substitute(s:runner_template(), '{cmd}', a:cmd, 'g')
  execute run_cmd
endfunction

function! s:assert_project()
  if empty(s:project_file())
    echohl ErrorMsg | echo 'No Xcode project file found!' | echohl None
    return 0
  else
    return 1
  endif
endfunction

function! s:base_command()
  return 'xcodebuild NSUnbufferedIO=YES ' . s:build_target() . ' ' . s:scheme()
endfunction

function! s:build_target()
  let xcworkspaceFile = glob('*.xcworkspace')
  if empty(xcworkspaceFile)
    return '-project' . s:cli_args(s:project_file())
  else
    return '-workspace' . s:cli_args(xcworkspaceFile)
  endif
endfunction

function! s:project_file()
  if !exists('s:chosen_project')
    let s:chosen_project = split(globpath(expand('.'), '*.xcodeproj'), '\n')[0]
  endif

  return s:chosen_project
endfunction

function! s:scheme()
  return '-scheme'. s:cli_args(s:scheme_name())
endfunction

function! s:scheme_name()
  if !exists('s:chosen_scheme')
    let s:chosen_scheme = system('source ' . s:bin_script('find_scheme.sh') . s:cli_args(s:project_file()))
  endif

  return s:chosen_scheme
endfunction

function! s:use_simulator()
  if !exists('s:use_simulator')
    call system('source ' . s:bin_script('use_simulator.sh') . s:cli_args(s:project_file(), s:scheme_name()))
    let s:use_simulator = !v:shell_error
  endif

  return s:use_simulator
endfunction

function! s:destination()
  if s:use_simulator()
    return s:iphone_simulator_destination()
  else
    return s:osx_destination()
  endif
endfunction

function! s:iphone_simulator_destination()
  return '-destination "platform=iOS Simulator,name=iPhone 6"'
endfunction

function! s:osx_destination()
  return '-destination "platform=OS X"'
endfunction

function! s:runner_template()
  if exists('g:xcode_run_command')
    return g:xcode_run_command
  else
    return s:default_run_command
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
  if exists('g:xcode_xcpretty_flags')
    return g:xcode_xcpretty_flags
  else
    return s:default_xcpretty_flags
  endif
endfunction

function! s:xcpretty_testing_flags()
  if exists('g:xcode_xcpretty_testing_flags')
    return g:xcode_xcpretty_testing_flags
  else
    return s:default_xcpretty_testing_flags
  endif
endfunction

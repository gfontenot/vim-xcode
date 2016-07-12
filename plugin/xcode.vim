command! Xbuild call <sid>build()
command! Xrun call <sid>run()
command! Xtest call <sid>test()
command! Xclean call <sid>clean()
command! -nargs=? -complete=file Xopen call <sid>open("<args>")
command! -nargs=1 -complete=file Xswitch call <sid>switch("<args>")

command! -nargs=1 -complete=custom,s:list_schemes
      \ Xscheme call <sid>set_scheme("<args>")

command! -nargs=1 -complete=custom,s:list_projects
      \ Xproject call <sid>set_project("<args>")

command! -nargs=1 -complete=custom,s:list_workspaces
      \ Xworkspace call <sid>set_workspace("<args>")

let s:default_runner_command = '! {cmd}'
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
    call s:execute_command(cmd)
  endif
endfunction

function s:run()
  if s:assert_project()
    let cmd = s:run_command()
    call s:execute_command(cmd)
  endif
endfunction

function! s:test()
  if s:assert_project()
    let cmd =  s:base_command() . ' ' . s:destination() . ' test' . s:xcpretty_test()
    call s:execute_command(cmd)
  endif
endfunction

function! s:clean()
  if s:assert_project()
    let cmd = s:base_command() . ' clean' . s:xcpretty()
    call s:execute_command(cmd)
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

function! s:set_workspace(workspace)
  let s:chosen_workspace = a:workspace
  unlet! s:available_schemes
  unlet! s:chosen_scheme
  unlet! s:use_simulator
endfunction

function! s:set_project(project)
  let s:chosen_project = a:project
  unlet! s:available_schemes
  unlet! s:chosen_scheme
  unlet! s:use_simulator
endfunction

function! s:set_scheme(scheme)
  let s:chosen_scheme = a:scheme
  unlet! s:use_simulator
endfunction

function! s:execute_command(cmd)
  let run_cmd = substitute(s:runner_template(), '{cmd}', a:cmd, 'g')
  execute run_cmd
endfunction

function! s:assert_project()
  if empty(s:project_files()) && empty(s:workspace_files())
    echohl ErrorMsg | echo 'No Xcode project file found!' | echohl None
    return 0
  else
    return 1
  endif
endfunction

function! s:base_command()
  return 'NSUnbufferedIO=YES xcrun xcodebuild ' . s:build_target_with_scheme()
endfunction

function! s:run_command()
  if s:use_simulator()
    return s:iphone_simulator_run_command()
  else
    return s:mac_run_command()
  endif
endfunction

function! s:iphone_simulator_run_command()
  return s:bin_script('run_ios_app') . ' ' . s:build_target_with_scheme()
endfunction

function! s:mac_run_command()
  return s:bin_script('run_mac_app') . ' ' . s:build_target_with_scheme()
endfunction

function! s:build_target_with_scheme()
  return s:build_target() . ' ' . s:scheme()
endfunction

function! s:build_target()
  if empty(s:workspace_files())
    return '-project' . s:cli_args(s:project_file())
  else
    return '-workspace' . s:cli_args(s:workspace_file())
  endif
endfunction

function! s:workspace_file()
  if !exists('s:chosen_workspace')
    if exists('g:xcode_workspace_file')
      let s:chosen_workspace = g:xcode_workspace_file
    else
      let s:chosen_workspace = split(s:workspace_files(), '\n')[0]
    endif
  endif

  return s:chosen_workspace
endfunction

function! s:list_workspaces(a, l, f)
  return s:workspace_files()
endfunction

function! s:workspace_files()
  return globpath(expand('.'), '*.xcworkspace')
endfunction

function! s:project_file()
  if !exists('s:chosen_project')
    if exists('g:xcode_project_file')
      let s:chosen_project = g:xcode_project_file
    else
      let s:chosen_project = split(s:project_files(), '\n')[0]
    endif
  endif

  return s:chosen_project
endfunction

function! s:list_projects(a, l, f)
  return s:project_files()
endfunction

function! s:project_files()
  return globpath(expand('.'), '*.xcodeproj')
endfunction

function! s:scheme()
  return '-scheme'. s:cli_args(s:scheme_name())
endfunction

function! s:scheme_name()
  if !exists('s:chosen_scheme')
    if exists('g:xcode_default_scheme')
      let s:chosen_scheme = g:xcode_default_scheme
    else
      let s:chosen_scheme = split(s:schemes(), '\n')[0]
    endif
  endif

  return s:chosen_scheme
endfunction

function! s:list_schemes(a, l, f)
  return s:schemes()
endfunction

function! s:schemes()
  if !exists('s:available_schemes')
    let s:available_schemes = system('source ' . s:bin_script('list_schemes.sh') . ' ' . s:build_target())
  endif

  return s:available_schemes
endfunction

function! s:use_simulator()
  if !exists('s:use_simulator')
    call system('source ' . s:bin_script('use_simulator.sh') . ' ' . s:build_target_with_scheme())
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
  if exists('g:xcode_runner_command')
    return g:xcode_runner_command
  else
    return s:default_runner_command
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

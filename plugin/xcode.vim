command! -nargs=? -complete=customlist,s:build_actions
      \ Xbuild call <sid>build("<args>")

command! -nargs=? -complete=customlist,s:list_simulators
      \ Xrun call <sid>run("<args>")

command! Xtest call <sid>test()
command! Xclean call <sid>clean()
command! -nargs=? -complete=file Xopen call <sid>open("<args>")
command! -nargs=1 -complete=file Xswitch call <sid>switch("<args>")

command! -nargs=1 -complete=customlist,s:list_schemes
      \ Xscheme call <sid>set_scheme("<args>")

command! -nargs=1 -complete=custom,s:list_projects
      \ Xproject call <sid>set_project("<args>")

command! -nargs=1 -complete=custom,s:list_workspaces
      \ Xworkspace call <sid>set_workspace("<args>")

command! -nargs=1 -complete=customlist,s:list_simulators
      \ Xsimulator call <sid>set_simulator("<args>")

function! s:system_runner()
  if has('nvim')
    return 'terminal'
  else
    return '!'
  endif
endfunction

let s:default_runner_command = s:system_runner() . ' {cmd}'

let s:default_xcpretty_flags = '--color'
let s:default_xcpretty_testing_flags = ''
let s:default_simulator = 'iPhone 6s'

let s:plugin_path = expand('<sfile>:p:h:h')

function! s:bin_script(name)
  return s:plugin_path . '/bin/' . a:name
endfunction

function! s:cli_args(...)
  return ' ' . join(map(copy(a:000), 'shellescape(v:val)'))
endfunction

function! s:build(actions)
  if s:assert_project()
    if empty(a:actions)
      let actions = 'build'
    else
      let actions = a:actions
    endif

    let cmd = s:base_command(actions, s:simulator()) . s:xcpretty()
    call s:execute_command(cmd)
  endif
endfunction

function! s:build_actions(a, l, f)
  return ['build', 'analyze', 'archive', 'test', 'installsrc', 'install', 'clean']
endfunction

function! s:run(simulator)
  if s:assert_project()
    if empty(a:simulator)
      let simulator = s:simulator()
    else
      let simulator = a:simulator
    endif

    let build_cmd = s:base_command('build', simulator) . s:xcpretty()
    let run_cmd = s:run_command(simulator)
    let cmd = build_cmd . ' \&\& ' . run_cmd
    call s:execute_command(cmd)
  endif
endfunction

function! s:test()
  if s:assert_project()
    let cmd =  s:base_command('test', s:simulator()) . s:xcpretty_test()
    call s:execute_command(cmd)
  endif
endfunction

function! s:clean()
  if s:assert_project()
    let cmd = s:base_command('clean', s:simulator()) . s:xcpretty()
    call s:execute_command(cmd)
  endif
endfunction

function! s:open(path)
  if s:assert_project()
    if empty(a:path)
      if s:workspace_exists()
        let file_path = s:workspace_file()
      else
        let file_path = s:project_file()
      endif
    else
      let file_path = a:path
    endif
    call system('source ' . s:bin_script('open_project.sh') . s:cli_args(file_path))
  endif
endfunction

function! s:switch(target)
  execute s:system_runner() . ' sudo xcode-select -s' . s:cli_args(a:target)
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

function! s:set_simulator(simulator)
  let s:chosen_simulator = a:simulator
endfunction

function! s:execute_command(cmd)
  let run_cmd = substitute(s:runner_template(), '{cmd}', a:cmd, 'g')
  execute run_cmd
endfunction

function! s:assert_project()
  if s:project_exists() || s:workspace_exists()
    return 1
  else
    echohl ErrorMsg | echo 'No Xcode project file found!' | echohl None
    return 0
  endif
endfunction

function! s:project_exists()
  if empty(s:project_files()) && !exists('g:xcode_project_file')
    return 0
  else
    return 1
  endif
endfunction

function! s:workspace_exists()
  if empty(s:workspace_files()) && !exists('g:xcode_workspace_file')
    return 0
  else
    return 1
  endif
endfunction

function! s:base_command(actions, simulator)
  return 'set -o pipefail; '
        \ . 'NSUnbufferedIO=YES xcrun xcodebuild '
        \ . a:actions
        \ . ' '
        \ . s:build_target_with_scheme()
        \ . ' '
        \ . s:destination(a:simulator)
endfunction

function! s:run_command(simulator)
  if s:use_simulator()
    return s:iphone_simulator_run_command(a:simulator)
  else
    return s:mac_run_command()
  endif
endfunction

function! s:iphone_simulator_run_command(simulator)
  return 'SIMULATOR="' . a:simulator . '" '
        \ . s:bin_script('run_ios_app')
        \ . ' '
        \ . s:build_target_with_scheme()
endfunction

function! s:mac_run_command()
  return s:bin_script('run_mac_app') . ' ' . s:build_target_with_scheme()
endfunction

function! s:build_target_with_scheme()
  return s:build_target() . ' ' . s:scheme()
endfunction

function! s:build_target()
  return s:build_target_flag() . ' ' . s:build_target_argument()
endfunction

function! s:build_target_flag()
  if s:workspace_exists()
    return '-workspace'
  else
    return '-project'
  endif
endfunction

function! s:build_target_argument()
  if s:workspace_exists()
    return s:cli_args(s:workspace_file())
  else
    return s:cli_args(s:project_file())
  endif
endfunction

function! s:workspace_file()
  if !exists('s:chosen_workspace')
    if exists('g:xcode_workspace_file')
      let s:chosen_workspace = g:xcode_workspace_file
    else
      let s:chosen_workspace = s:workspace_files()[0]
    endif
  endif

  return s:chosen_workspace
endfunction

function! s:list_workspaces(a, l, f)
  return s:workspace_files()
endfunction

function! s:workspace_files()
  return globpath(expand('.'), '*.xcworkspace', 0, 1)
endfunction

function! s:project_file()
  if !exists('s:chosen_project')
    if exists('g:xcode_project_file')
      let s:chosen_project = g:xcode_project_file
    else
      let s:chosen_project = s:project_files()[0]
    endif
  endif

  return s:chosen_project
endfunction

function! s:list_projects(a, l, f)
  return s:project_files()
endfunction

function! s:project_files()
  return globpath(expand('.'), '*.xcodeproj', 0, 1)
endfunction

function! s:scheme()
  return '-scheme'. s:cli_args(s:scheme_name())
endfunction

function! s:scheme_name()
  if !exists('s:chosen_scheme')
    if exists('g:xcode_default_scheme')
      let s:chosen_scheme = g:xcode_default_scheme
    else
      let s:chosen_scheme = s:schemes()[0]
    endif
  endif

  return s:chosen_scheme
endfunction

function! s:list_schemes(a, l, f)
  return s:schemes()
endfunction

function! s:schemes()
  if !exists('s:available_schemes')
    call s:get_available_schemes()
  endif
  return s:available_schemes
endfunction

function! s:get_available_schemes()
  let scheme_command = 'source '
                    \ . s:bin_script('list_schemes.sh')
                    \ . ' '
                    \ . '-f'
                    \ . ' '
                    \ . s:build_target_flag()
                    \ . ' '
                    \ . '-t'
                    \ . ' '
                    \ . s:build_target_argument()

  if exists('g:xcode_scheme_ignore_pattern')
    let scheme_command .= ' ' . '-i' . s:cli_args(g:xcode_scheme_ignore_pattern)
  endif

  let s:available_schemes = systemlist(scheme_command)
endfunction

function! s:simulator()
  if !exists('s:chosen_simulator')
    if exists('g:xcode_default_simulator')
      let s:chosen_simulator = g:xcode_default_simulator
    else
      let s:chosen_simulator = s:default_simulator
    endif
  endif

  return s:chosen_simulator
endfunction

function! s:list_simulators(a, l, f)
  return s:available_simulators()
endfunction

function! s:available_simulators()
  if !exists('s:simulators')
    let s:simulators = systemlist('source ' . s:bin_script('list_available_simulators.sh'))
  endif

  return s:simulators
endfunction

function! s:use_simulator()
  if !exists('s:use_simulator')
    let platform = system('source ' . s:bin_script('project_platform.sh') . ' ' . s:build_target_with_scheme())
    let s:use_simulator = platform ==# "ios"
  endif

  return s:use_simulator
endfunction

function! s:destination(simulator)
  if s:use_simulator()
    return s:iphone_simulator_destination(a:simulator)
  else
    return s:osx_destination()
  endif
endfunction

function! s:iphone_simulator_destination(simulator)
  return '-destination "platform=iOS Simulator,name=' . a:simulator . '"'
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

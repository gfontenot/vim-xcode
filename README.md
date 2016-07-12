# xcode.vim

Plugin for building and testing Xcode projects from within Vim


## Installation

Recommended installation with [vundle](https://github.com/gmarik/vundle):

```vim
Plugin 'gfontenot/vim-xcode'
```

## Usage

`xcode.vim` is a thin wrapper around `xcodebuild`, with some helper methods of
its own. It dynamically finds the project in the current working directory
(with support for workspaces as well) and builds the first scheme it finds.

 - `:Xbuild` will build the project
 - `:Xrun` will run the app in the iOS Simulator
 - `:Xtest` will test the project
 - `:Xclean` will clean the project's build directory
 - `:Xopen` will open the project or a specified file in Xcode
 - `:Xswitch` will switch the selected version of Xcode (requires sudo)
 - `:Xworkspace` will let you manually specify the workspace to build and test
 - `:Xproject` will let you manually specify the project to build and test
 - `:Xscheme` will let you manually specify the scheme to build and test

### Project and Scheme configuration

If `xcode.vim` is having trouble determining the workspace/project/scheme to
use, you can set local variables to manually specify the configuration you
expect:

```
let g:xcode_workspace_file = 'path/to/workspace.xcworkspace'
let g:xcode_project_file = 'path/to/project.xcodeproj'
let g:xcode_default_scheme = 'MyScheme'
```

Note that manually specifying a different project or scheme with the
`:Xworkspace`, `:Xproject`, or `:Xscheme` commands will override these values
until you restart vim.

This is most useful when placed inside a project-specific vimrc ([See the Argo
vimrc as an example][argo-vimrc]). You can make sure Vim loads these local
vimrc files by default by setting the following in your main vimrc:

[argo-vimrc]: https://github.com/thoughtbot/Argo/blob/master/.vimrc

```
set secure  " Don't let external configs do scary shit
set exrc    " Load local vimrc if found
```

### `xcpretty` support

[`xcpretty`] is a gem for improving the output of xcodebuild. By default, if
you have it installed, `xcode.vim` will pipe all `xcodebuild` output through
`xcpretty` with the `--color` flag.

[`xcpretty`]: https://github.com/supermarin/xcpretty

For customization options, see the [included help doc][help] (`:help xcode`
from within Vim).

[help]: https://github.com/gfontenot/vim-xcode/blob/master/doc/xcode.txt

### Async builds

By default, `xcode.vim` will take over the current terminal session to build
and display the build/test log. However, with long build times, this might not
be ideal. To help with this, `xcode.vim` allows you to customize the runner by
setting `g:xcode_runner_command`. This variable should be a template string,
where `{cmd}` will be replaced by the `xcodebuild` command.

```vim
let g:xcode_runner_command = 'VtrSendCommandToRunner! {cmd}'
```

This is useful for using `xcode.vim` with other plugins such as
[`vim-tmux-runner`] and [`vim-dispatch`].

[`vim-tmux-runner`]: https://github.com/christoomey/vim-tmux-runner
[`vim-dispatch`]: https://github.com/tpope/vim-dispatch

For more info, see the [included help doc][help] (`:help xcode` from within
Vim).

## License

xcode.vim is copyright © 2015 Gordon Fontenot. It is free software, and may be
redistributed under the terms specified in the `LICENSE` file.

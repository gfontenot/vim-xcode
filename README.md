# xcodebuild.vim

Plugin for building and testing Xcode projects from within Vim


## Installation

Recommended installation with [vundle](https://github.com/gmarik/vundle):

```vim
Plugin 'gfontenot/vim-xcodebuild'
```

## Usage

`xcodebuild.vim` is a thin wrapper around `xcodebuild` itself. It dynamically
finds the project in the current working directory (with support for
workspaces as well) and builds the first scheme it finds.

 - `XBuild` will build the project
 - `XTest` will test the project in the iOS simulator

### `xcpretty` support

[`xcpretty`] is a gem for improving the output of xcodebuild. By default, if you
have it installed, `xcodebuild.vim` will pipe all `xcodebuild` output through
`xcpretty` with the `--color` flag.

[`xcpretty`]: https://github.com/supermarin/xcpretty

If you'd like to customize the output from `xcpretty`, you can do so by
setting a couple of global variables in your `vimrc`:

 - `g:xcodebuild_xcpretty_flags` will be passed to build and test commands. By
   default, this is `--color`.
 - `g:xcodebuild_xcpretty_test_flags` will be passed to test commands only. By
   default, this is empty.

```vim
let g:xcodebuild_xcpretty_flags = '--color --no-utf'
let g:xcoebuild_xcpretty_test_flags = '--test'
```

See the [`xcpretty` formatting documentation][xcpretty-doc] for available
options.

[xcpretty-doc]: https://github.com/supermarin/xcpretty#formats

### Async builds

By default, `xcodebuild.vim` will take over the current terminal session to
build and display the build/test log. However, with long build times, this
might not be ideal. To help with this, `xcocebuild.vim` allows you to
customize the runner by setting `g:xcodebuild_runner`:

```vim
let g:xcodebuild_runner = 'VtrSendCommandToRunner'
```

This is useful for using `xcodebuild.vim` with other plugins such as
[`vim-tmux-runner`] and [`vim-dispatch`].

[`vim-tmux-runner`]: https://github.com/christoomey/vim-tmux-runner
[`vim-dispatch`]: https://github.com/tpope/vim-dispatch

## License

xcodeproj.vim is copyright © 2015 Gordon Fontenot It is free software, and may be
redistributed under the terms specified in the `LICENSE` file.

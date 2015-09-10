# xcodebuild.vim

Super WIP plugin for building and testing Xcode projects from within Vim


## Installation

Recommended installation with [vundle](https://github.com/gmarik/vundle):

```vim
Plugin 'gfontenot/vim-xcodebuild'
```

## Usage

`xcodebuild.vim` is a thin wrapper around `xcodebuild` itself. It dynamically
finds the project in the current working directory (with support for
workspaces as well) and builds the first scheme it finds. If you have
`xcpretty` installed, it will pipe the output through that with the `--color`
and `--test` flags.

 - `XcodebuildBuild` will build the project
 - `XcodebuildTest` will test the project in the iOS simulator

## License

xcodeproj is copyright © 2015 Gordon Fontenot It is free software, and may be
redistributed under the terms specified in the `LICENSE` file.

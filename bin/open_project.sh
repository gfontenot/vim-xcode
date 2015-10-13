#!/usr/bin/env sh

xcode=$(xcode-select -p | sed 's|/Contents/Developer||')
open -a "$xcode" .

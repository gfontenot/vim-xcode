#!/usr/bin/env sh

set -o pipefail

xcodebuild -list -project "$@" 2>/dev/null \
  | awk '/Schemes:/,0' \
  | tail -n +2 \
  | sed -e "s/^[[:space:]]*//"

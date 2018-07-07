#!/usr/bin/env sh

set -o pipefail

xcrun xcodebuild -list "$@" 2>/dev/null \
  | awk '/Schemes:/,0' \
  | tail -n +2 \
  | sed -E '/demo|Demo|Example|example/d' \
  | sed -e "s/^[[:space:]]*//"

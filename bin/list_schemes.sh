#!/usr/bin/env sh

set -o pipefail

ignore_pattern="$1"

if [[ "$ignore_pattern" == "-workspace" ]]; then
    xcrun xcodebuild -list 2>/dev/null \
      | awk '/Schemes:/,0' \
      | tail -n +2 \
      | sed -e "s/^[[:space:]]*//"
else
    xcrun xcodebuild -list 2>/dev/null \
      | awk '/Schemes:/,0' \
      | tail -n +2 \
      | sed -E "$ignore_pattern" \
      | sed -e "s/^[[:space:]]*//"
fi

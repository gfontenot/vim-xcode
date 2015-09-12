#!/usr/bin/env sh

set -o pipefail

xcodebuild -list -project "$@" 2>/dev/null \
  | awk '/Schemes:/ { getline; print }' \
  | tr -d "\n "

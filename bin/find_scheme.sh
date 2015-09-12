#!/usr/bin/env sh

xcodebuild -list -project "$@" 2>/dev/null \
  | awk '/Schemes:/ { getline; print }' \
  | tr -d "\n "

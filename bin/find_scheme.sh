#!/usr/bin/env sh

xcodebuild -list -project "$@" \
  | awk '/Schemes:/ { getline; print }' \
  | tr -d "\n "

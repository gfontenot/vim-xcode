#!/usr/bin/env sh

xcodebuild -project "$1" -scheme "$2" -showBuildSettings 2>/dev/null \
  | grep -q CORRESPONDING_SIMULATOR_SDK_NAME

#!/bin/bash

sim_info=$(xcrun xcodebuild -showBuildSettings "$@" 2>/dev/null \
  | grep CORRESPONDING_SIMULATOR_SDK_NAME)

if [[ "$sim_info" == *"appletv"* ]]; then
  platform="tvos"
elif [[ "$sim_info" == *"watch"*  ]]; then
  platform="watchos"
elif [[ "$sim_info" == *"iphone"* ]]; then
  platform="ios"
else
  platform="macos"
fi

printf "$platform"

#!/usr/bin/env sh

set -o pipefail

project="$1"
scheme="$2"

xcodebuild -project "$project" -scheme "$scheme" -showBuildSettings \
  | grep CORRESPONDING_SIMULATOR_SDK_NAME \
  2>&1 > /dev/null

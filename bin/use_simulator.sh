#!/usr/bin/env sh

set -o pipefail

xcrun xcodebuild -showBuildSettings $@ 2>/dev/null \
  | grep -q CORRESPONDING_SIMULATOR_SDK_NAME

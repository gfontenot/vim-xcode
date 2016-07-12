#!/usr/bin/env sh

set -o pipefail

xcrun simctl list devicetypes \
  | tail -n +2 \
  | sed -E "s/[[:space:]]\(.*$//"

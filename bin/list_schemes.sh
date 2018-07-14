#!/usr/bin/env sh

set -o pipefail

while getopts "t:i:" opt; do
  case $opt in
    t) flag_and_target="$OPTARG";;
    i) ignore_pattern="$OPTARG";;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument" >&2
      exit 1
      ;;
  esac
done

flag="$(echo "$flag_and_target" | cut -d ' ' -f1)"
target="$(echo "$flag_and_target" | cut -d ' ' -f2)"

schemes="$(
  xcrun xcodebuild -list "$flag" "$target" 2>/dev/null \
  | awk '/Schemes:/,0' \
  | tail -n +2 \
  | sed -e "s/^[[:space:]]*//"
)"

if [ -z "$ignore_pattern" ]; then
  echo "$schemes"
else
  echo "$schemes" | sed -E "$ignore_pattern"
fi


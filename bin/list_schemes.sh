#!/usr/bin/env sh

set -o pipefail

while getopts "f:t:i:" opt; do
  case $opt in
    f) target_type_flag="$OPTARG";;
    t) target="$OPTARG";;
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

schemes="$(
  xcrun xcodebuild -list "$target_type_flag" "$target" 2>/dev/null \
  | awk '/Schemes:/,0' \
  | tail -n +2 \
  | sed -e "s/^[[:space:]]*//"
)"

if [ -z "$ignore_pattern" ]; then
  echo "$schemes"
else
  echo "$schemes" | sed -E "$ignore_pattern"
fi

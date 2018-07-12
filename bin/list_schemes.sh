#!/usr/bin/env sh

set -o pipefail

while getopts "t:i:" opt; do
  case $opt in
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
  xcrun xcodebuild -list 2>/dev/null \
  | awk '/Schemes:/,0' \
  | tail -n +2 \
  | sed -e "s/^[[:space:]]*//"
)"

if [[ $ignore_pattern ]]; then
  echo "$schemes" | sed -E "$ignore_pattern"
else
  echo "$schemes"
fi


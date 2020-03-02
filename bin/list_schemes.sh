#!/usr/bin/env sh

set -o pipefail

ignore_schemes=()

while getopts "f:t:i:e:" opt; do
  case $opt in
    f) target_type_flag="$OPTARG";;
    t) target="$OPTARG";;
    i) ignore_pattern="$OPTARG";;
    e) ignore_schemes+=("$OPTARG");;
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

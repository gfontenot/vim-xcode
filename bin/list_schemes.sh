#!/usr/bin/env sh

set -o pipefail

get_schemes() {
  xcrun xcodebuild -list "$1" "$2" 2>/dev/null \
    | awk '/Schemes:/,0' \
    | tail -n +2 \
    | sed -e "s/^[[:space:]]*//"
}

get_sources_ignore() {
  if [ ! -e "$1" ]; then
    return
  fi
  case "$1" in
    *xcworkspace) type='-workspace';;
    *xcodeproj) type='-project';;
    *) return;;
  esac
  echo "^($(get_schemes "$type" "$1" | tr '\n' '|' | sed 's/|*$//'))$"
}

ignore_sources_pattern=""

while getopts "f:t:i:e:" opt; do
  case $opt in
    f) target_type_flag="$OPTARG";;
    t) target="$OPTARG";;
    i) ignore_pattern="$OPTARG";;
    e) ignore_sources_pattern="$ignore_sources_pattern|$(get_sources_ignore "$OPTARG")";;
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

schemes="$(get_schemes "$target_type_flag" "$target")"

if [ -n "$ignore_sources_pattern" ]; then
  ignore_sources_pattern="/$(echo "$ignore_sources_pattern" | sed 's/^|*//')/d"
  schemes="$(echo "$schemes" | sed -E "$ignore_sources_pattern")"
fi

if [ -z "$ignore_pattern" ]; then
  echo "$schemes"
else
  echo "$schemes" | sed -E "$ignore_pattern"
fi

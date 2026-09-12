#!/bin/sh
printf '\033c\033]0;%s\a' Tutorial
base_path="$(dirname "$(realpath "$0")")"
"$base_path/spiel.x86_64" "$@"

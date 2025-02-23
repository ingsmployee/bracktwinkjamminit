#!/bin/sh
echo -ne '\033c\033]0;dogsbuilddogsbuilddogs\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/dogsbuilddogsbuilddogs.x86_64" "$@"

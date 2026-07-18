#!/bin/sh

set -eu

if [ $# -lt 1 ]; then
    echo "Usage: $0 <*.alb>..."
    exit 1
fi

for FILE in "$@"; do
    jq --arg file "${FILE}" \
        -r '.userPatch | to_entries[] | "\($file)\tCH\(.key+1):\(.value."PATCH%COM"|join(""))"' \
    "${FILE}"
done

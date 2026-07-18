#!/bin/sh
#
# BOSS IR-2
#
# PATCH%COM is currently treated as a 7-byte (56-bit) opaque value.
#
# Hex output is intended for human-readable diffs, while the bit stream
# is provided for format analysis and reverse engineering.
#
# The encoded data is assumed to represent the DSP's parameter state
# rather than physical control positions. The stored values may be
# quantized representations of user controls rather than direct ADC
# readings. Seven-bit grouping remains a working hypothesis based on
# observed data.

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

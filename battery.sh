#!/bin/sh

set -eu

SYSPWR="/sys/class/power_supply"

if test $(cat ${SYSPWR}/AC/online) -eq 1; then
    echo "*** Running on AC ***"
else
    echo "*** Running on Battery ***"
fi

echo -n "\
internal = $(cat ${SYSPWR}/BAT0/model_name)\tcapacity = $(cat ${SYSPWR}/BAT0/capacity)%\tstatus = $(cat ${SYSPWR}/BAT0/status)\n\
external = $(cat ${SYSPWR}/BAT1/model_name)\tcapacity = $(cat ${SYSPWR}/BAT1/capacity)%\tstatus = $(cat ${SYSPWR}/BAT1/status)\n"

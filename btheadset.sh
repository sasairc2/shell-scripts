#!/usr/bin/env bash

set -u

BTHCTL="bluetoothctl"
BTHCTL_DISCON_WAIT=2
BTHDEV="Victor HA-A22T"
BTHMAC="XX:XX:XX:XX:XX:XX"

connect_device() {
    ${BTHCTL} connect "${BTHMAC}"
}

disconnect_device() {
    ${BTHCTL} disconnect "${BTHMAC}"
}

reconnect_device() {
    disconnect_device && \
        sleep ${BTHCTL_DISCON_WAIT} && \
        connect_device
}

print_help() {
    echo "Usage: $(basename $0) [-cdrqhv] [-n device] [-m address]"
}

print_version() {
    cat <<EOF
$0

BTHCTL="${BTHCTL}"
BTHCTL_DISCON_WAIT=${BTHCTL_DISCON_WAIT}
BTHDEV="${BTHDEV}"
BTHMAC="${BTHMAC}"
EOF
}

FLAGS=(0 0 0 0)

while getopts "cdrqn:m:hv" OPT; do
    case "${OPT}" in
        c)
            FLAGS[0]=1
            ;;
        d)
            FLAGS[1]=1
            ;;
        r)
            FLAGS[2]=1
            ;;
        q)
            FLAGS[3]=1
            ;;
        n)
            BTHDEV="${OPTARG}"
            ;;
        m)
            BTHMAC="${OPTARG}"
            ;;
        h)
            print_help
            exit 0
            ;;
        v)
            print_version
            exit 0
            ;;
        \?)
            exit 1
            ;;
        *)
            exit 1
            ;;
    esac
done

test ${FLAGS[3]} -eq 1 && \
    exec > /dev/null 2>&1
if [ ${FLAGS[0]} == 1 ]; then
    connect_device
elif [ ${FLAGS[1]} == 1 ]; then
    disconnect_device
elif [ ${FLAGS[2]} == 1 ]; then
    reconnect_device
fi

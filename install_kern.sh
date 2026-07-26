#!/usr/bin/env bash

set -eu

CP="cp"
ARCH="x86_64"
#SRC="/usr/src/linux"
DEST="/boot"
KERNEL=("bzImage" "vmlinuz")
VERSION="$(make kernelversion)"

${CP} "arch/${ARCH}/boot/${KERNEL[0]}" "${DEST}/${KERNEL[1]}-${VERSION}" && \
    ${CP} "System.map" "${DEST}/System.map-${VERSION}" && \
    ${CP} ".config" "${DEST}/config-${VERSION}" && \
    mkinitramfs -o "${DEST}/initrd.img-${VERSION}" "${VERSION}"

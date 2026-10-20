#!/usr/bin/env bash
#
# rsync_backup.sh - Backup ${HOME} to external drives using rsync.
# Skips cache, logs operations, avoids duplicate runs.
#
# For --include and --exclude,
# see https://tech.nitoyon.com/ja/blog/2013/03/26/rsync-include-exclude/
# for details.

set -u

SRC="${HOME}"
DEST=("/Volumes/DT01ACA200-APR2019")
HOSTNAME="$(hostname -s)"
LOGFILE="${HOME}/local/var/log/rsync.log"
RSYNC="/opt/homebrew/bin/rsync"
RSYNC_OPT="-av --delete"
RSYNC_NICE=""

print_help() {
    echo "Usage: $(basename $0) [-nhv] [-p priority]"
}

print_version() {
    cat <<EOF
$0

SRC="${HOME}"
DEST="${DEST}"
HOSTNAME="${HOSTNAME}"
LOGFILE="${LOGFILE}"
RSYNC="${RSYNC}"
RSYNC_OPT="${RSYNC_OPT}"
RSYNC_NICE="${RSYNC_NICE}"
EOF
}

# Check options
while getopts "np:vh" OPT; do
    case "${OPT}" in
        n)
            RSYNC_OPT="${RSYNC_OPT} --dry-run"
            ;;
        p)
            if nice -n ${OPTARG} true > /dev/null 2>&1; then
                RSYNC_NICE="nice -n ${OPTARG}"
            else 
                echo "$(basename $0): ${OPTARG}: invalid nice value" > /dev/stderr
                exit 1
            fi
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

# Check if rsync is already running
PID=$(pgrep -f "rsync\s.*${SRC}" | tr '\n' ', ' | sed 's/, $//')
if [ -n "${PID}" ]; then
    echo "$(LANG=C date): ${RSYNC} [${PID}] is already running" | \
        tee -a "${LOGFILE}"
    exit 0
fi

# Check if the backup destination is mounted
for ((i = 0; i < ${#DEST[@]}; i++)); do
    df | grep "${DEST[$i]}" || exit 1
done

# Create the destination directory if it does not exist
for ((i = 0; i < ${#DEST[@]}; i++)); do
    mkdir -p "${DEST[$i]}/${HOSTNAME}/${USER}/"
done

# Run rsync
for ((i = 0; i < ${#DEST[@]}; i++)); do
    echo "$(LANG=C date): ${RSYNC} ${RSYNC_OPT} ${SRC}/ ${DEST[$i]}/${HOSTNAME}/${USER}/: start" | \
        tee -a "${LOGFILE}"
    ${RSYNC_NICE} ${RSYNC} ${RSYNC_OPT} \
        --exclude=".AppleDouble" \
        --exclude=".DS_Store" \
        --exclude=".Trash/" \
        --exclude=".Trashes/" \
        --exclude="Desktop/" \
        --exclude="Downloads/" \
        --exclude="Library/" \
        --exclude="Movies/iMovie Theater.theater/" \
        --exclude="Movies/iMovieライブラリ.imovielibrary/" \
        --exclude="Movies/Motion Templates.localized/" \
        --exclude="Movies/TV/" \
        --exclude="Pictures/Photo Boothライブラリ/" \
        --exclude="Pictures/Photos Library.photoslibrary/" \
        --exclude="Public/" \
        --exclude="Templates/" \
        "${SRC}/" "${DEST[$i]}/${HOSTNAME}/${USER}/" 2>&1 | \
        grep -Ev 'Operation not permitted|/AppleInternal/|Permission denied' | \
        tee -a "${LOGFILE}"

    # Always end
    echo "$(LANG=C date): ${RSYNC} ${RSYNC_OPT} ${SRC}/ ${DEST[$i]}/${HOSTNAME}/${USER}/: end" | \
        tee -a "${LOGFILE}"
done

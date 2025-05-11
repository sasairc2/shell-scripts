#!/bin/bash
#
# rsync_backup.sh - Backup ${HOME} to external drives using rsync.
# Skips cache, logs operations, avoids duplicate runs.
#

SRC="${HOME}"
DEST=("/Volumes/backup_1")
HOSTNAME="$(hostname -s)"
LOGFILE="${HOME}/local/var/log/rsync.log"

RSYNC="/opt/homebrew/bin/rsync"
#RSYNC_OPT="-av --delete"
RSYNC_OPT="-av --dry-run"
#RSYNC_NICE="nice -n 16"

# Check if rsync is already running
PID=$(pgrep -f "rsync\s.*${SRC}" | tr '\n' ', ' | sed 's/, $//')
if [ -n "${PID}" ]; then
    echo "$(LANG=C date): ${RSYNC} [${PID}] is already running" | tee -a "${LOGFILE}"
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
    echo "$(LANG=C date): ${RSYNC} ${RSYNC_OPT} ${SRC}/ ${DEST[$i]}/${HOSTNAME}/${USER}/: start" | tee -a "${LOGFILE}"
    ${RSYNC_NICE} ${RSYNC} ${RSYNC_OPT} \
        --include="Library/Caches/Homebrew/" \
        --exclude="Library/Caches/*" \
        --exclude="Library/Containers/" \
        --exclude="Library/Group Containers/" \
        --exclude="Library/CloudStorage/" \
        --exclude="Library/Logs/" \
        --exclude="Library/Application Support/Slack/Service Worker/CacheStorage/" \
        --exclude=".DS_Store" \
        --exclude=".AppleDouble" \
        --exclude=".Trash/" \
        --exclude=".Trashes/" \
        --exclude="Movies/" \
        --exclude="Pictures/" \
        --exclude="Downloads/" \
        --exclude="Public/" \
        --exclude="Google Drive/" \
        "${SRC}/" "${DEST[$i]}/${HOSTNAME}/${USER}/" 2>&1 | grep -Ev 'Operation not permitted|/AppleInternal/|Permission denied' | tee -a "${LOGFILE}"

    # Always end
    echo "$(LANG=C date): ${RSYNC} ${RSYNC_OPT} ${SRC}/ ${DEST[$i]}/${HOSTNAME}/${USER}/: end" | tee -a "${LOGFILE}"
done

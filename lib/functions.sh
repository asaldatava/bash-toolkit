#!/bin/bash

source config/file.env

function backup() {
    rotate_backups
    calc_checksum
}

function rotate_backups() {
    CURRENT_DATE=$(date '+%Y%m%d%H%M%S')
    ARCHIVE_NAME=backup_${CURRENT_DATE}.tar.gz
    LOG_NAME_INFO=logs/backup_${CURRENT_DATE}_INFO.log
    LOG_NAME_ERROR=logs/backup_${CURRENT_DATE}_ERROR.log
if [[ ! -d "$DESTINATION_DIR" ]]; then
  mkdir -p "$DESTINATION_DIR"
  echo "INFO: creating a ${DESTINATION_DIR} directory"
fi
echo "Check if source exists"
if [[ ! -f "$SOURCE" ]]; then
  echo "ERROR: $SOURCE does not exist"
  exit 1
else
  echo "INFO: creating ${ARCHIVE_NAME} in ${DESTINATION_DIR}"
  exit 0
fi

  tar -cvzf $DESTINATION_DIR/${ARCHIVE_NAME} $SOURCE > ${LOG_NAME_INFO} 2>${LOG_NAME_ERROR}
# Clean up old backups
BACKUPS=($(ls -dt $DESTINATION_DIR/backup_*))
BACKUP_COUNT=${#BACKUPS[@]}
if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
  for (( i="$MAX_BACKUPS"; i<$BACKUP_COUNT; i++ ))
  do
    rm -rf "${BACKUPS[$i]}"
    echo "Old backup deleted: ${BACKUPS[$i]}"
  done
fi
exit 0
}

function calc_checksum() {
    echo -n ${ARCHIVE_NAME} | sha256sum > checksum.txt
}

#function log_info() {
#
#}
#
#function log_error() {
#
#}

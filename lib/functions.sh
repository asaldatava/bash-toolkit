#!/bin/bash

source config/file.env

function rotate_backups() {
    CURRENT_DATE=$(date '+%Y%m%d%H%M%S')
    ARCHIVE_NAME=backup_${CURRENT_DATE}.tar.gz
    LOG_NAME=logs/backup_${CURRENT_DATE}.log
if [[ ! -d "$DESTINATION_DIR" ]]; then
  mkdir -p "$DESTINATION_DIR"
fi

if [[ ! -d "$SOURCE_DIRECTORY" ]]; then
  >>${LOG_NAME} 2>&1
fi

    tar -cvzf $DESTINATION_DIR/${ARCHIVE_NAME} $SOURCE_DIRECTORY  >>${LOG_NAME} 2>&1
    calc_checksum

    # Clean up old backups
    count=$(ls -tr "$DESTINATION_DIR" | wc -l)
    if [[ $count -gt $MAX_BACKUPS ]]; then
      # Delete oldest backups until reaching the desired number
      for file in $(ls -t "$DESTINATION_DIR" | tail -n +$(($count - $MAX_BACKUPS))); do
        rm -f "$DESTINATION_DIR/$file"
      done
    fi
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

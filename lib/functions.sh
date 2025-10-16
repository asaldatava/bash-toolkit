#!/bin/bash
set -x

source config/file.env

CURRENT_DATE=$(date '+%Y%m%d%H%M%S')
LOG_NAME_INFO=logs/backup_${CURRENT_DATE}_INFO.log
LOG_NAME_ERROR=logs/backup_${CURRENT_DATE}_ERROR.log

exec 2>$LOG_NAME_ERROR
exec >$LOG_NAME_INFO

function backup() {
   if ! command -v backup &> /dev/null; then
        error_exit "Required command not found" 2
   fi
   if ! rotate_backups; then
    error_exit "rotate backups failed"
   fi
    calc_checksum
    clean_old_backups
}

function rotate_backups() {
  if [ "$#" -ne 4 ]; then
    show_usage
  fi
  echo "Argument 1: $1"
  echo "Argument 2: $2"
  echo "Argument 3: $3"
  echo "Argument 4: $4"

ARCHIVE_NAME=backup_${CURRENT_DATE}.tar.gz

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
  tar -cvzf $DESTINATION_DIR/${ARCHIVE_NAME} $SOURCE 2>&1
}

function clean_old_backups() {
    BACKUPS=($(ls -dt $DESTINATION_DIR/backup_*))
    BACKUP_COUNT=${#BACKUPS[@]}
    if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
      for (( i="$MAX_BACKUPS"; i<$BACKUP_COUNT; i++ ))
      do
        rm -rf "${BACKUPS[$i]}"
        echo "Old backup deleted: ${BACKUPS[$i]}"
      done
    fi
    if [ $? -ne 0 ]; then
      echo "Error: Failed to clean old backup"
      exit 1
    fi
}

function calc_checksum() {
    echo -n ${ARCHIVE_NAME} | sha256sum > checksum.txt
}

function error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

function log_error() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp ERROR: $1" >> "$LOG_NAME_ERROR"
    echo "ERROR: $1" >&2
}

function log() {
  if [[ ! -f "$PATH_TO_FILE" ]]; then
    echo "ERROR: $PATH_TO_FILE does no exist"
    exit 1
  fi
  grep -m "$MAX_SEARCH" -F "$PATTERN" "$PATH_TO_FILE"  2>&1
  exit 0
}

  function show_usage() {
    echo "Usage: $0 [command] [source] [destination] [backups-number]"
    exit 1
  }
#!/bin/bash
set -euo pipefail

source config/file.env

CURRENT_DATE=$(date '+%Y%m%d%H%M%S')
LOG_DIR=logs
LOG_NAME_INFO=${LOG_DIR}/backup_${CURRENT_DATE}_INFO.log
LOG_NAME_ERROR=${LOG_DIR}/backup_${CURRENT_DATE}_ERROR.log

if [[ ! -d "$LOG_DIR" ]]; then
  mkdir -p "$LOG_DIR"
  echo "INFO: creating a ${LOG_DIR} directory"
fi

exec 2>"$LOG_NAME_ERROR"
exec 1>"$LOG_NAME_INFO"

function backup() {
    rotate_backups
    clean_old_backups
    exit 0
}

function rotate_backups() {
local ARCHIVE_NAME="backup_${CURRENT_DATE}.tar.gz"

if [[ ! -d "$DESTINATION_DIR" ]]; then
  mkdir -p "$DESTINATION_DIR"
  echo "INFO: creating a ${DESTINATION_DIR} directory"
fi
echo "Check if source exists"
if [[ ! -e "$SOURCE" ]]; then
  echo "ERROR: $SOURCE does not exist"
  error_exit
else
  echo "INFO: creating ${ARCHIVE_NAME} in ${DESTINATION_DIR}"
fi
  tar -cvzf "${DESTINATION_DIR}/${ARCHIVE_NAME}" "$SOURCE" 2>&1
  sha256sum "${DESTINATION_DIR}/${ARCHIVE_NAME}" > checksum
  echo " $(sha256sum --check checksum) "
  exit 0
}

function clean_old_backups() {
    BACKUPS=($(ls -dt $DESTINATION_DIR/backup_*.tar.gz))          # word-splitting; brak *.tar.gz; `ls` wywali błąd gdy brak plików
    BACKUP_COUNT=${#BACKUPS[@]}
    if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
      for (( i="$MAX_BACKUPS"; i<"$BACKUP_COUNT"; i++ ))
      do
        rm -f "${BACKUPS[$i]}"
           if [ $? -ne 0 ]; then                                  # `$?` tutaj już nie odnosi się do `rm`; sprawdzaj od razu po komendzie
               echo "Error: Failed to clean old backup"
               error_exit                                              # `exit` w funkcji → zamyka cały skrypt
             fi
        echo "Old backup deleted: ${BACKUPS[$i]}"
      done
    fi
    exit 0
}

function error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

function log() {
  if [[ ! -f "$PATH_TO_FILE" ]]; then
    echo "ERROR: $PATH_TO_FILE does not exist"              # literówka: "does not exist"
    `return`/`error_exit`                                               # `exit` w funkcji → nie rób tego; użyj `return`/`error_exit`
  fi
  grep -m "$MAX_SEARCH" -F "$PATTERN" "$PATH_TO_FILE"  2>&1 # `-m` potrzebuje liczby; 2>&1 miesza wynik z błędami
  exit 0                                                   # jw. – nie `exit` w funkcji
}



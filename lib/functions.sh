#!/bin/bash
set -euo pipefail

source config/file.env

CURRENT_DATE=$(date '+%Y%m%d%H%M%S')
LOG_DIR=logs

if [[ ! -d "$LOG_DIR" ]]; then
  mkdir -p "$LOG_DIR"
  echo "INFO: creating a ${LOG_DIR} directory"
fi

function error_exit() {
  echo "Error: $1" >&2
  exit "${2:-1}"
}

function backup() {
  LOG_NAME_INFO=${LOG_DIR}/backup_${CURRENT_DATE}_INFO.log
  LOG_NAME_ERROR=${LOG_DIR}/backup_${CURRENT_DATE}_ERROR.log
  exec 2>"$LOG_NAME_ERROR"
  exec 1>"$LOG_NAME_INFO"
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
    BACKUPS=($(ls -dt $DESTINATION_DIR/backup_*.tar.gz))
    BACKUP_COUNT=${#BACKUPS[@]}
    if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
      for (( i="$MAX_BACKUPS"; i<"$BACKUP_COUNT"; i++ ))
      do
        rm -f "${BACKUPS[$i]}"
           if [ $? -ne 0 ]; then
               echo "Error: Failed to clean old backup"
               error_exit
             fi
        echo "Old backup deleted: ${BACKUPS[$i]}"
      done
    fi
    exit 0
}


function log() {
  LOG_NAME_INFO=${LOG_DIR}/logs_${CURRENT_DATE}_INFO.log
  LOG_NAME_ERROR=${LOG_DIR}/logs_${CURRENT_DATE}_ERROR.log
  exec 2>"$LOG_NAME_ERROR"
  exec 1>"$LOG_NAME_INFO"
  if [[ ! -f "$PATH_TO_FILE" ]]; then
    echo "ERROR: $PATH_TO_FILE does not exist"
    error_exit
  fi
  if [ -r "$PATH_TO_FILE" ]; then
      cat "$PATH_TO_FILE"
  else
      # Permission denied or file does not exist
      if [ ! -e "$PATH_TO_FILE" ]; then
          echo "Error: File $PATH_TO_FILE does not exist."
      else
          echo "Error: Permission denied while reading $PATH_TO_FILE."
      fi
      error_exit
  fi
  grep  "$PATTERN" "$PATH_TO_FILE" | tail -"$MAX_SEARCH" 2>&1 | tee /dev/tty | wc -l > grepcount
  exit 0
}

function sysinfo() {
  local REPORT_NAME="report_${CURRENT_DATE}.txt"
  LOG_NAME_INFO=${LOG_DIR}/reports_${CURRENT_DATE}_INFO.log
  LOG_NAME_ERROR=${LOG_DIR}/reports_${CURRENT_DATE}_ERROR.log
  exec 2>"$LOG_NAME_ERROR"
  exec 1>"$LOG_NAME_INFO"
  REPORTS_DIR=reports
  if [[ ! -d "$REPORTS_DIR" ]]; then
    mkdir -p "$REPORTS_DIR"
    echo "INFO: creating a $REPORTS_DIR directory"
  fi

  hostname -f > $REPORTS_DIR/$REPORT_NAME
  date -d "$(uptime -s)" +"%Y-%m-%d_%H:%M"  >> $REPORTS_DIR/$REPORT_NAME
  grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}' >> $REPORTS_DIR/$REPORT_NAME
  echo "grep Active: /proc/meminfo | tr -d '[:space:]' | sed 's/Active://'" >> $REPORTS_DIR/$REPORT_NAME
  df -h . | awk 'NR==2 {print 100-$5}' | sed 's/%//' >> $REPORTS_DIR/$REPORT_NAME

{
echo "----------------------------------------------------------------------------------------------"
printf "| %-20s | %-20s | %-10s | %-10s | %-20s |\n" "HOST" "UPTIME" "CPU" "MEMORY" "AVAILABLE_SPACE"
echo "----------------------------------------------------------------------------------------------"

count=0
while read -r line; do
    values[$count]="$line"
    count=$((count + 1))

    if [ $count -eq 5 ]; then
        printf "| %-20s | %-20s | %-10s | %-10s | %-20s |\n" \
               "${values[0]}" "${values[1]}" "${values[2]}" "${values[3]}" "${values[4]}"
        count=0
    fi
done < "$REPORTS_DIR/$REPORT_NAME"
echo "-----------------------------------------------------------------------------------------------"
} >> "$REPORTS_DIR/$REPORT_NAME"
}

function menu() {
    LOG_NAME_INFO=${LOG_DIR}/menu_${CURRENT_DATE}_INFO.log
    LOG_NAME_ERROR=${LOG_DIR}/menu_${CURRENT_DATE}_ERROR.log
    exec 2>"$LOG_NAME_ERROR"
    exec 1>"$LOG_NAME_INFO"
  case "$0" in
    backup)    # this is the name of the argument triggering the function - could be different, for instance f1
      backup  # this is the name of the function to run
      ;;

    log)    # this is the name of the argument triggering the function - could be different, for instance f2
      log   # this is the name of the function to run
      ;;

    sysinfo)    # this is the name of the argument triggering the function - could be different, for instance f3
      sysinfo   # this is the name of the function to run
      ;;

    menu)    # this is the name of the argument triggering the function - could be different, for instance f4
      menu   # this is the name of the function to run
      ;;

    \?) # Invalid option
       echo "Error: Invalid option"
       exit;;

    *)
      echo "Usage: $0 {backup|log|sysinfo|menu}"
      ;;
  esac
}


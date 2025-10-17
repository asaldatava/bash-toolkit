#!/bin/bash
set -x                       # rozważ też: set -euo pipefail

source config/file.env

CURRENT_DATE=$(date '+%Y%m%d%H%M%S')
LOG_NAME_INFO=logs/backup_${CURRENT_DATE}_INFO.log
LOG_NAME_ERROR=logs/backup_${CURRENT_DATE}_ERROR.log

exec 2>$LOG_NAME_ERROR       # jeśli katalog logs/ nie istnieje → poleci; daj wcześniej `mkdir -p logs`
exec >$LOG_NAME_INFO         # brak cudzysłowów; używaj `exec 1>"$LOG_NAME_INFO"`

function backup() {
   if ! command -v backup &> /dev/null; then
        error_exit "Required command not found" 2
   fi                         # sprawdzasz istnienie *tej funkcji*, a nie narzędzi; sprawdź `tar`/`sha256sum`
   if ! rotate_backups; then
    error_exit "rotate backups failed"
   fi
    calc_checksum             # zależy od ARCHIVE_NAME z rotate_backups; pilnuj kolejności
    clean_old_backups
}

function rotate_backups() {
  if [ "$#" -ne 4 ]; then
    show_usage
  fi                          # wymagane 4 argi, a i tak nie są używane → to tylko blokuje działanie

  echo "Argument 1: $1"
  echo "Argument 2: $2"
  echo "Argument 3: $3"
  echo "Argument 4: $4"       # debug zbędny, skoro argi nie są używane

ARCHIVE_NAME=backup_${CURRENT_DATE}.tar.gz  # daj cudzysłowy; możesz rozważyć `local ARCHIVE_NAME=...`

if [[ ! -d "$DESTINATION_DIR" ]]; then
  mkdir -p "$DESTINATION_DIR"
  echo "INFO: creating a ${DESTINATION_DIR} directory"
fi
echo "Check if source exists"
if [[ ! -f "$SOURCE" ]]; then            # -f nie złapie katalogów; lepiej `[[ ! -e "$SOURCE" ]]`
  echo "ERROR: $SOURCE does not exist"
  exit 1                                  # `exit` w funkcji zabija cały skrypt → użyj `return`/`error_exit`
else
  echo "INFO: creating ${ARCHIVE_NAME} in ${DESTINATION_DIR}"
  exit 0                                  # kończysz przed `tar` → archiwum nigdy nie powstaje
fi
  tar -cvzf $DESTINATION_DIR/${ARCHIVE_NAME} $SOURCE 2>&1  # brak cudzysłowów → ryzyko rozbicia ścieżek
}

function clean_old_backups() {
    BACKUPS=($(ls -dt $DESTINATION_DIR/backup_*))          # word-splitting; brak *.tar.gz; `ls` wywali błąd gdy brak plików
    BACKUP_COUNT=${#BACKUPS[@]}
    if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
      for (( i="$MAX_BACKUPS"; i<$BACKUP_COUNT; i++ ))
      do
        rm -rf "${BACKUPS[$i]}"                            # -rf za mocne dla plików; wystarczy `rm -f`
        echo "Old backup deleted: ${BACKUPS[$i]}"
      done
    fi
    if [ $? -ne 0 ]; then                                  # `$?` tutaj już nie odnosi się do `rm`; sprawdzaj od razu po komendzie
      echo "Error: Failed to clean old backup"
      exit 1                                               # `exit` w funkcji → zamyka cały skrypt
    fi
}

function calc_checksum() {
    echo -n ${ARCHIVE_NAME} | sha256sum > checksum.txt     # sumujesz napis, nie plik; i brak cudzysłowów/ścieżki docelowej
}

function error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

function log_error() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp ERROR: $1" >> "$LOG_NAME_ERROR"       # ok, ale stderr i tak idzie do tego pliku
    echo "ERROR: $1" >&2
}

function log() {
  if [[ ! -f "$PATH_TO_FILE" ]]; then
    echo "ERROR: $PATH_TO_FILE does no exist"              # literówka: "does not exist"
    exit 1                                                 # `exit` w funkcji → nie rób tego; użyj `return`/`error_exit`
  fi
  grep -m "$MAX_SEARCH" -F "$PATTERN" "$PATH_TO_FILE"  2>&1 # `-m` potrzebuje liczby; 2>&1 miesza wynik z błędami
  exit 0                                                   # jw. – nie `exit` w funkcji
}

  function show_usage() {
    echo "Usage: $0 [command] [source] [destination] [backups-number]"
    exit 1                                                 # usage mówi o 4 argach, ale skrypt ich nie używa → niespójność
  }

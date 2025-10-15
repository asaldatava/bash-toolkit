#!/bin/bash

source lib/functions.sh

backup
log

case "$1" in
    "") ;;
    backup) "$@"; exit;;
    log) "$@"; exit;;
    *) log "Unknown function: $1()"; exit 2;;
esac

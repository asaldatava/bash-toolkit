#!/bin/bash
set -x

source lib/functions.sh

case "$1" in
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

  *)
    echo "Usage: $0 {backup|log|sysinfo|menu}"
    ;;
esac

backup
log
sysinfo
menu
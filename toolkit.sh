#!/bin/bash
set -x

source lib/functions.sh

case "$1" in
  backup)    # this is the name of the argument triggering the function - could be different, for instance f1
    backup   # this is the name of the function to run
    shift
    ;;

  log)    # this is the name of the argument triggering the function - could be different, for instance f2
    log   # this is the name of the function to run
    shift
    ;;

  *)
    echo "Usage: $0 {backup|log}"
    ;;
esac

backup
log
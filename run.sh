#!/bin/bash

while getopts "p:s:d" OPTIONS; do case $OPTIONS in
  d) VERBOSE_OPTIONS="-vv" ;;
  p) PORT="$OPTARG" ;;
  s) SERVICE_PATH="$OPTARG" ;;
  *) exit 1 ;;
esac; done; shift $(( OPTIND - 1 ))

: ${PORT:="8080"}
: ${SERVICE:="./service.sh"}
: ${VERBOSE_OPTIONS:=""}
: ${SERVICE_PATH:="./path"}

socat \
  $VERBOSE_OPTIONS \
  TCP-LISTEN:${PORT},crlf,reuseaddr,fork \
  EXEC:"${SERVICE} -p ${SERVICE_PATH}"

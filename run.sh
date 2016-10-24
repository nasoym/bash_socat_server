#!/bin/bash

while getopts "ds" OPTIONS; do case $OPTIONS in
  d) VERBOSE_OPTIONS="-vv" ;;
  s) SHORT="1" ;;
  *) exit 1 ;;
esac; done; shift $(( OPTIND - 1 ))

: ${PORT:="1234"}
: ${SERVICE:="./service.sh"}
: ${VERBOSE_OPTIONS:=""}

socat \
  $VERBOSE_OPTIONS \
  TCP-LISTEN:${PORT},crlf,reuseaddr,fork \
  EXEC:"${SERVICE} -p ./path"

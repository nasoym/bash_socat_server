#!/bin/bash

while getopts "d:p:r:v" OPTIONS; do case $OPTIONS in
  v) VERBOSE_OPTIONS="-vv" ;;
  p) PORT="$OPTARG" ;;
  r) ROUTES_PATH=" -r $OPTARG" ;;
  d) DEFAULT_ROUTE_HANDLER="-d $OPTARG" ;;
  *) exit 1 ;;
esac; done; shift $(( OPTIND - 1 ))

: ${PORT:="8080"}
: ${VERBOSE_OPTIONS:=""}
: ${SERVICE:="./service.sh"}
: ${ROUTES_PATH:=" -r ./example_handler/routes"}

socat \
  $VERBOSE_OPTIONS \
  TCP-LISTEN:${PORT},reuseaddr,fork \
  EXEC:"${SERVICE} ${ROUTES_PATH} ${DEFAULT_ROUTE_HANDLER}"


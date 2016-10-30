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
: ${SERVICE:="$(dirname $0)/service.sh"}
: ${ROUTES_PATH:=" -r $(dirname $0)/example_handlers"}
: ${DEFAULT_ROUTE_HANDLER:=" -d $(dirname $0)/example_handlers/default"}

socat \
  $VERBOSE_OPTIONS \
  TCP-LISTEN:${PORT},reuseaddr,fork,su=nobody \
  EXEC:"${SERVICE} ${ROUTES_PATH} ${DEFAULT_ROUTE_HANDLER}"


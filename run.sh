#!/bin/bash
set -ef -o pipefail

while getopts "d:p:r:vsc" OPTIONS; do case $OPTIONS in
  v) VERBOSE_OPTIONS="-vv" ;;
  p) PORT="$OPTARG" ;;
  r) ROUTES_PATH="$OPTARG" ;;
  d) DEFAULT_ROUTE_HANDLER="$OPTARG" ;;
  c) run_as_nobody=0 ;;
  *) exit 1 ;;
esac; done; shift $(( OPTIND - 1 ))

: ${PORT:="8080"}
: ${VERBOSE_OPTIONS:=""}
: ${SERVICE:="$(dirname $0)/service.sh"}

: ${ROUTES_PATH:="$(dirname $0)/example_handlers"}
: ${DEFAULT_ROUTE_HANDLER:="${ROUTES_PATH}/default"}

: ${ROUTES_PATH_ARGUMENT:=" -r $ROUTES_PATH"}
: ${DEFAULT_ROUTE_HANDLER_ARGUMENT:=" -d $DEFAULT_ROUTE_HANDLER"}

: ${run_as_nobody:=1}

if [[ "$run_as_nobody" -eq 1 ]];then
  : ${run_as_user:=",su=nobody"}
else
  : ${run_as_user:=""}
fi

socat \
  $VERBOSE_OPTIONS \
  TCP-LISTEN:${PORT},reuseaddr,fork${run_as_user} \
  EXEC:"${SERVICE} ${ROUTES_PATH_ARGUMENT} ${DEFAULT_ROUTE_HANDLER_ARGUMENT}"


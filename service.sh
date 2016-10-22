#!/bin/bash

function upper() { echo "$@" | tr '[:lower:]' '[:upper:]'; }

while getopts "s" OPTIONS; do case $OPTIONS in
  s) SHORT="1" ;;
  *) exit 1 ;;
esac; done; shift $(( OPTIND - 1 ))

read -r REQUEST_METHOD REQUEST_URI REQUEST_HTTP_VERSION

while read -r HEADER_LINE; do 
  [[ "$HEADER_LINE" =~ ^$ ]]&& { break; } 
  HEADER_KEY="${HEADER_LINE/%: */}"
  HEADER_KEY="$(upper ${HEADER_KEY//-/_} )"
  HEADER_VALUE="${HEADER_LINE/#*: /}"
  declare "REQUEST_HEADER_${HEADER_KEY}"="$HEADER_VALUE"
done

unset HEADER_KEY HEADER_VALUE HEADER_LINE

if [[ -n "$REQUEST_HEADER_CONTENT_LENGTH" ]] && [[ "$REQUEST_HEADER_CONTENT_LENGTH" -gt "0" ]];then
  read -r -d '' -n "$REQUEST_HEADER_CONTENT_LENGTH" REQUEST_CONTENT
fi

REQUEST_PATH="${REQUEST_URI/%\?*/}"

if [[ -f "./path${REQUEST_PATH}" ]];then
  RESPONSE_CONTENT=$(echo "$REQUEST_CONTENT" | . ./path${REQUEST_PATH})
    # | read -d'' RESPONSE_CONTENT
  echo "HTTP/1.0 200 OK"
  echo "Cache-Control : no-cache, private"
  echo "Content-Length : ${#RESPONSE_CONTENT}"

# RESPONSE_HEADER_Foo="abcdef"
  # set | grep "RESPONSE_HEADER"
  # set
  # echo "$RESPONSE_HEADER_Foo"

  echo "Date: $(date)"
  echo
  echo "${RESPONSE_CONTENT}"

else
  echo "HTTP/1.0 200 OK"
  echo "Date: $(date)"
  echo
fi


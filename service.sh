#!/bin/bash

while getopts "s" OPTIONS; do case $OPTIONS in
  s) SHORT="1" ;;
  *) exit 1 ;;
esac; done; shift $(( OPTIND - 1 ))

read -r REQUEST_METHOD REQUEST_URI REQUEST_HTTP_VERSION

. ./read_headers_to_vars.sh

if [[ -n "$REQUEST_HEADER_CONTENT_LENGTH" ]] && [[ "$REQUEST_HEADER_CONTENT_LENGTH" -gt "0" ]];then
  read -r -d '' -n "$REQUEST_HEADER_CONTENT_LENGTH" REQUEST_CONTENT
fi

REQUEST_PATH="${REQUEST_URI/%\?*/}"
REQUEST_QUERIES="${REQUEST_URI/#*\?/}"

if [[ -f "./path${REQUEST_PATH}" ]];then

  RESPONSE_CONTENT=$(echo "$REQUEST_CONTENT" | . ./path${REQUEST_PATH})
  echo "HTTP/1.0 200 OK"
  echo "Cache-Control : no-cache, private"
  echo "Content-Length : ${#RESPONSE_CONTENT}"

  echo "Date: $(date)"
  echo
  echo "${RESPONSE_CONTENT}"

else
  echo "HTTP/1.0 200 OK"
  echo "Date: $(date)"
  echo
fi


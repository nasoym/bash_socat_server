#!/bin/bash

while getopts "p:s" OPTIONS; do case $OPTIONS in
  p) SEARCH_PATH="$OPTARG" ;;
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

function echo_response_status_line() { 
  STATUS_CODE=${1-200}
  STATUS_TEXT=${2-OK}
  echo "HTTP/1.0 ${STATUS_CODE} ${STATUS_TEXT}"
}

function echo_response_default_headers() { 
  echo "Date: $(date -u "+%a, %d %b %Y %T GMT")"
  echo "Server: Socat Bash"
}

REQUEST_PATH_SEGMENT="${REQUEST_PATH}"
while [[ -n "$REQUEST_PATH_SEGMENT" ]] && [[ "$REQUEST_PATH_SEGMENT" != "/" ]] && [[ -z "$MATCHING_FILE" ]]; do
  MATCHING_FILE="$(find . -type f -path "${SEARCH_PATH}${REQUEST_PATH_SEGMENT}" | head -n1)"
  if [[ -n "$MATCHING_FILE" ]];then
    REQUEST_SUBPATH=${REQUEST_PATH/#$REQUEST_PATH_SEGMENT/}
    break
  fi
  REQUEST_PATH_SEGMENT="$( dirname $REQUEST_PATH_SEGMENT)"
done
unset REQUEST_PATH_SEGMENT

if [[ -n "$MATCHING_FILE" ]];then

  RESPONSE_CONTENT=$(echo "$REQUEST_CONTENT" | . ${MATCHING_FILE})
  if [[ $? = 3 ]] && [[ "$RESPONSE_CONTENT" =~ ^HTTP\/[0-9]+\.[0-9]+\ [0-9]+ ]];then
    # insert headers ?
    echo "${RESPONSE_CONTENT}"
  else
    echo_response_status_line  
    echo_response_default_headers
    # use ending for content type
    echo "Content-Length : ${#RESPONSE_CONTENT}"
    echo
    echo "${RESPONSE_CONTENT}"
  fi

else
  echo_response_status_line 404 "NOT FOUND"
  echo_response_default_headers
  echo
fi


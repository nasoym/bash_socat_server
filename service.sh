#!/bin/bash

while getopts "r:d:" OPTIONS; do case $OPTIONS in
  r) ROUTES_PATH="$OPTARG" ;;
  d) DEFAULT_ROUTE_HANDLER="$OPTARG" ;;
  *) exit 1 ;;
esac; done; shift $(( OPTIND - 1 ))

read -r REQUEST_METHOD REQUEST_URI REQUEST_HTTP_VERSION

. ./read_headers_to_vars.sh

if [[ -n "$REQUEST_HEADER_CONTENT_LENGTH" ]] && [[ "$REQUEST_HEADER_CONTENT_LENGTH" -gt "0" ]];then
  read -r -d '' -n "$REQUEST_HEADER_CONTENT_LENGTH" REQUEST_CONTENT
fi

REQUEST_PATH="${REQUEST_URI/%\?*/}"
if [[ "${REQUEST_URI}" =~ \? ]]; then
  REQUEST_QUERIES="${REQUEST_URI/#*\?/}"
fi

function echo_response_status_line() { 
  STATUS_CODE=${1-200}
  STATUS_TEXT=${2-OK}
  echo -e "HTTP/1.0 ${STATUS_CODE} ${STATUS_TEXT}\r"
}

function echo_response_default_headers() { 
  # DATE=$(date +"%a, %d %b %Y %H:%M:%S %Z")
  echo -e "Date: $(date -u "+%a, %d %b %Y %T GMT")\r"
  echo -e "Expires: $(date -u "+%a, %d %b %Y %T GMT")\r"
  echo -e "Server: $(cat version.txt)\r"
  echo -e "Connection: close\r"
}

REQUEST_PATH_SEGMENT="${REQUEST_PATH}"
until [[ -z "$REQUEST_PATH_SEGMENT" ]] ; do
  if [[ -f "${ROUTES_PATH}${REQUEST_PATH_SEGMENT}" ]];then
    MATCHING_ROUTE_FILE="${ROUTES_PATH}${REQUEST_PATH_SEGMENT}"
    REQUEST_SUBPATH="${REQUEST_PATH/#$REQUEST_PATH_SEGMENT/}"
    break
  fi
  if [[ "${REQUEST_PATH_SEGMENT}" =~ /$ ]];then
    REQUEST_PATH_SEGMENT="${REQUEST_PATH_SEGMENT/%\//}"
  else
    REQUEST_PATH_SEGMENT="$(dirname $REQUEST_PATH_SEGMENT)"
  fi
done
unset REQUEST_PATH_SEGMENT

if [[ -z "$MATCHING_ROUTE_FILE" ]];then
    if [[ -f "${DEFAULT_ROUTE_HANDLER}" ]]; then
      MATCHING_ROUTE_FILE="${DEFAULT_ROUTE_HANDLER}"
    elif [[ -f "${ROUTES_PATH}/${DEFAULT_ROUTE_HANDLER}" ]]; then
      MATCHING_ROUTE_FILE="${ROUTES_PATH}/${DEFAULT_ROUTE_HANDLER}"
    fi
fi

if [[ -n "$MATCHING_ROUTE_FILE" ]];then
  RESPONSE_CONTENT="$(echo "$REQUEST_CONTENT" | . ${MATCHING_ROUTE_FILE})"
  if [[ "$RESPONSE_CONTENT" =~ ^HTTP\/[0-9]+\.[0-9]+\ [0-9]+ ]];then
    echo "${RESPONSE_CONTENT}"
  else
    echo_response_status_line  
    echo_response_default_headers
    echo -e "Content-Type: text/html\r"
    echo -e "Content-Length: ${#RESPONSE_CONTENT}\r"
    echo -e "\r"
    echo "${RESPONSE_CONTENT}"
  fi
else
  echo_response_status_line 404 "Not Found"
  echo_response_default_headers
  echo -e "\r"
fi


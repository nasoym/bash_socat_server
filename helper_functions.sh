#!/bin/bash

function urldecode() {
  INPUT="$@"
  url_encoded="${INPUT//+/ }"
  printf '%b\n' "${url_encoded//%/\\x}"
}
export -f urldecode

function urlencode() {
  echo -n "$@" | while IFS= read -n 1 C; do 
    case $C in
        [a-zA-Z0-9.~_-]) printf "$C" ;;
        *) printf '%%%02X' "'$C" ;; 
    esac
  done
  printf '\n'
}
export -f urlencode

function echo_response_status_line() { 
  STATUS_CODE=${1-200}
  STATUS_TEXT=${2-OK}
  echo -e "HTTP/1.0 ${STATUS_CODE} ${STATUS_TEXT}\r"
}
export -f echo_response_status_line

export SERVER_VERSION="$(cat $(dirname $0)/VERSION)"

function echo_response_default_headers() { 
  # DATE=$(date +"%a, %d %b %Y %H:%M:%S %Z")
  echo -e "Date: $(date -u "+%a, %d %b %Y %T GMT")\r"
  echo -e "Expires: $(date -u "+%a, %d %b %Y %T GMT")\r"
  echo -e "Server: $SERVER_VERSION\r"
  echo -e "Connection: close\r"
}
export -f echo_response_default_headers


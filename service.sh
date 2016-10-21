#!/bin/bash

read REQUEST_METHOD REQUEST_URI REQUEST_HTTP_VERSION

while read HEADER_LINE; do 
  [[ "$HEADER_LINE" =~ ^$ ]]&& { 
    break; 
  } 
  HEADER_KEY=$(echo "$HEADER_LINE" | sed 's/^\([^:]*\):.*/\1/g' | sed 's/-/_/g' | tr '[:lower:]' '[:upper:]')
  HEADER_VALUE=$(echo "$HEADER_LINE" | sed 's/^[^:]*: \(.*\)/\1/g')
  declare "HEADER_${HEADER_KEY}"="$HEADER_VALUE"
done

read -n $HEADER_CONTENT_LENGTH CONTENT_BODY

REQUEST_PATH=$(echo "$REQUEST_URI" | sed 's/^\([^?]*\).*$/\1/g')

if [[ -f "./path${REQUEST_PATH}" ]];then
    echo "$CONTENT_BODY" | . ./path${REQUEST_PATH}
else
  echo "HTTP/1.0 200 OK"
  # echo "Cache-Control : no-cache, private"
  # echo "Content-Length : 107"
  echo "Date: $(date)"
  echo

  echo "REQUEST_METHOD:$REQUEST_METHOD"
  echo "REQUEST_PATH:$REQUEST_PATH"
  echo "REQUEST_URI:$REQUEST_URI"
  set | grep "^HEADER_"
  echo "CONTENT_BODY:$CONTENT_BODY"

fi


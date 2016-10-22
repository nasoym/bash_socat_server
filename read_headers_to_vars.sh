#!/bin/bash

function upper() { echo "$@" | tr '[:lower:]' '[:upper:]'; }

while read -r HEADER_LINE; do 
  [[ "$HEADER_LINE" =~ ^$ ]]&& { break; } 
  HEADER_KEY="${HEADER_LINE/%: */}"
  HEADER_KEY="$(upper ${HEADER_KEY//-/_} )"
  HEADER_VALUE="${HEADER_LINE/#*: /}"
  declare "REQUEST_HEADER_${HEADER_KEY}"="$HEADER_VALUE"
done

unset HEADER_KEY HEADER_VALUE HEADER_LINE

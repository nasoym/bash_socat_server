#!/bin/bash

: ${PORT:="1234"}
: ${SERVICE:="./service.sh"}

socat \
  -vv \
  TCP-LISTEN:${PORT},crlf,reuseaddr,fork \
  EXEC:"${SERVICE}"

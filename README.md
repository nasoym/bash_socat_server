# Socat Bash Http Server

This repository contains a very simple bash socat http server.
Socat is used to forward incoming data from a tcp port(8080) to
a bash script.
The bash script extract headers and body and writes the information
in environment variables.
Based on the request path files are executed and the response is 
sent back to the client.

## options
* -p <port number> : port
* -r <path> : path for route handlers
* -d <path> : path to default route handler script
* -v : turn on verbose logging
* -s : run scripts as user nobody

## todos / issues /questions
* avoid injection via request headers
* avoid .. in path in order to avoid executing arbitrary files


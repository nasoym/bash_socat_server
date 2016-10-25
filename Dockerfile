FROM alpine
MAINTAINER Sinan Goo

RUN apk update && apk upgrade
RUN apk --no-cache add socat bash

WORKDIR /socat_server

ADD *.sh /socat_server/
ADD version.txt /socat_server/
ADD example_handler /handlers

EXPOSE 8080

ENTRYPOINT ["./run.sh"]
CMD ["-r /handlers/routes", "-d /handlers/default"]


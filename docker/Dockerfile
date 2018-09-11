FROM kong:0.13.1-alpine
#FROM kong:0.14.0-alpine

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories
RUN apk update
RUN apk add aws-cli jq curl

COPY ./docker-entrypoint.sh /
RUN chmod 700 /docker-entrypoint.sh

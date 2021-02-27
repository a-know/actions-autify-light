FROM alpine:3.12.3

RUN apk update && apk add curl jq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

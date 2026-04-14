# syntax=docker/dockerfile:1
FROM scratch AS builder

ADD alpine-minirootfs-3.21.3-aarch64.tar /

RUN apk add --no-cache go git openssh-client && \
    mkdir -p -m 0700 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

WORKDIR /app

RUN --mount=type=ssh git clone git@github.com:karolina417/pawcho6.git .

ARG VERSION="1.0.0"

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags "-X 'main.VERSION=${VERSION}'" -o myapp main.go

FROM nginx:alpine

LABEL org.opencontainers.image.source="https://github.com/karolina417/pawcho6"

COPY --from=builder /app/myapp /usr/local/bin/myapp

COPY --from=builder /app/default.conf /etc/nginx/conf.d/default.conf

RUN apk add --no-cache curl

HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

CMD /usr/local/bin/myapp & nginx -g "daemon off;"
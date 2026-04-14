# ETAP 1:
FROM scratch AS builder

ADD alpine-minirootfs-3.21.3-aarch64.tar /

RUN apk add --no-cache go

ARG VERSION="1.0.0"
WORKDIR /app
COPY main.go .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-X 'main.VERSION=${VERSION}'" -o myapp main.go

# ETAP 2:
FROM nginx:alpine

COPY --from=builder /app/myapp /usr/local/bin/myapp

COPY default.conf /etc/nginx/conf.d/default.conf

RUN apk add --no-cache curl

HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

CMD /usr/local/bin/myapp & nginx -g "daemon off;"
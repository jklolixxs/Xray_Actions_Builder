FROM --platform=$BUILDPLATFORM golang:alpine AS builder
WORKDIR /go/src/github.com/XTLS/Xray-core
ARG TARGETOS TARGETARCH BRANCH
ENV CGO_ENABLED=0
ENV GOOS=$TARGETOS
ENV GOARCH=$TARGETARCH

RUN set -ex \
  && apk add git build-base git \
  && git clone -b $BRANCH --single-branch https://github.com/XTLS/Xray-core /go/src/github.com/XTLS/Xray-core \
  && go build -trimpath \
    -o /go/bin/xray \
    -ldflags "-s -w -buildid=" \
    ./main

FROM --platform=$TARGETPLATFORM alpine AS dist
RUN set -ex \
  && apk upgrade \
  && apk add bash tzdata ca-certificates \
  && rm -rf /var/cache/apk/* \
  && mkdir -p /usr/share/xray

COPY --from=builder /go/bin/xray /usr/local/bin/xray
ENTRYPOINT [ "/usr/local/bin/xray" ]

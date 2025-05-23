FROM golang:alpine as builder

WORKDIR /app

COPY cloudflare.go cloudflare.go
COPY main.go main.go
COPY prometheus.go prometheus.go
COPY go.mod go.mod
COPY go.sum go.sum

RUN go get -d -v
RUN CGO_ENABLED=0 GOOS=linux go build --ldflags '-w -s -extldflags "-static"' -o cloudflare_exporter .

FROM alpine:3.19

RUN apk update && apk add ca-certificates curl

COPY --from=builder /app/cloudflare_exporter cloudflare_exporter

ENV CF_API_KEY ""
ENV CF_API_EMAIL ""

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:9199/metrics || exit 1

ENTRYPOINT [ "./cloudflare_exporter" ]

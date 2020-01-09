FROM golang:1.13.5 AS builder

ARG AWS_ACCESS_KEY
ARG AWS_SECRET_KEY

ENV GOPATH="/go" \
    GOROOT="/usr/local/go" \
    AWS_ACCESS_KEY=$AWS_ACCESS_KEY \
    AWS_SECRET_KEY=$AWS_SECRET_KEY

WORKDIR /go/src/github.com/percona/rds_exporter
COPY . ./
RUN make build

FROM alpine:latest

COPY --from=builder /go/src/github.com/percona/rds_exporter/rds_exporter  /bin/
# COPY config.yml           /etc/rds_exporter/config.yml

RUN apk update && \
    apk add ca-certificates && \
    update-ca-certificates

EXPOSE      9042
ENTRYPOINT  [ "/bin/rds_exporter", "--config.file=/etc/rds_exporter/config.yml" ]
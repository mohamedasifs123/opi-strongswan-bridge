# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2022-2023 Dell Inc, or its subsidiaries.

FROM docker.io/library/golang:1.21.4-alpine as builder

WORKDIR /app

# Download necessary Go modules
COPY go.mod ./
COPY go.sum ./
RUN go mod download

# build an app
COPY cmd/ cmd/
COPY pkg/ pkg/
RUN go build -v -o /opi-vici-bridge /app/cmd/...

# second stage to reduce image size
FROM alpine:3.19
COPY --from=builder /opi-vici-bridge /
COPY --from=docker.io/fullstorydev/grpcurl:v1.8.9-alpine /bin/grpcurl /usr/local/bin/
EXPOSE 50051
CMD [ "/opi-vici-bridge", "-port=50051" ]
HEALTHCHECK CMD grpcurl -plaintext localhost:50051 list || exit 1

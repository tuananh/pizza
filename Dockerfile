#syntax=docker/dockerfile:1.4

FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.1.0 AS xx

FROM --platform=${BUILDPLATFORM:-linux/amd64} cgr.dev/chainguard/go:1.20 AS builder
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

COPY --from=xx / /
WORKDIR /app
COPY . .
RUN --mount=target=/go/pkg/mod,type=cache \
    --mount=target=/root/.cache,type=cache \
    xx-go build -ldflags="${GO_LDFLAGS}" -o pizza-oven .

FROM --platform=${TARGETPLATFORM:-linux/amd64} cgr.dev/chainguard/glibc-dynamic
COPY --from=builder /app/pizza-oven /usr/bin/
CMD ["/usr/bin/pizza-oven"]
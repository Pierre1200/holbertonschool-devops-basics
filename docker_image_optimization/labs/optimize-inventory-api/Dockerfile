# syntax=docker/dockerfile:1
FROM golang:1.25-alpine AS builder

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY cmd/ ./cmd/
COPY internal/ ./internal/

RUN go test ./...

RUN CGO_ENABLED=0 go build -o /out/inventory-api ./cmd/api

FROM scratch

COPY --from=builder /out/inventory-api /inventory-api

USER 65532:65532

EXPOSE 8080

ENTRYPOINT ["/inventory-api"]
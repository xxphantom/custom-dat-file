FROM golang:1.22-alpine AS builder

WORKDIR /build

# Копируем domain-list-community
COPY domain-list-community/ ./domain-list-community/

# Собираем
WORKDIR /build/domain-list-community
RUN go mod download && go build -o dlc-build .

# Финальный образ
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

# Копируем собранный бинарник
COPY --from=builder /build/domain-list-community/dlc-build /app/

# Создаем директории
RUN mkdir -p /app/lists /app/output

# Точка входа
ENTRYPOINT ["/app/dlc-build", "-datapath=/app/lists", "-outputdir=/app/output", "-outputname=custom.dat"]
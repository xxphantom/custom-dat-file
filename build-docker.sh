#!/bin/bash

set -e

echo "Building DAT file using Docker..."

# Собираем Docker образ
docker build -t custom-dat-builder .

# Запускаем сборку
docker run --rm \
    -v "$(pwd)/lists:/app/lists:ro" \
    -v "$(pwd)/output:/app/output" \
    custom-dat-builder

echo "Successfully built output/custom.dat"
#!/bin/bash

# Собрать образ если ещё не собран
if ! docker images | grep -q asm64; then
    echo "Собираю образ..."
    docker build -t asm64 .
fi

docker run --platform linux/amd64 -it --rm -v $(pwd):/projects asm64 bash
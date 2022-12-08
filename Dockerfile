FROM docker.io/library/debian:stable-slim

WORKDIR /assignment

RUN apt update && \
    apt upgrade -y && \
    apt install -y build-essential meson clang ssh flex bison zsh bash curl wget tar && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

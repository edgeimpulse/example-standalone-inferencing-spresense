FROM ubuntu:20.04

WORKDIR /app

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
        wget \
        build-essential \
        python3-dev \
        zip \
        gcc-arm-none-eabi \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

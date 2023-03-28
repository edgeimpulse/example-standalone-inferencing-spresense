FROM ubuntu:20.04

WORKDIR /app

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
        wget \
        build-essential \
        python3-dev \
        python3-pip \
        python3-setuptools \
        zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# GCC ARM
RUN if [ $(uname -m) = "x86_64" ]; then export ARCH=x86_64; else export ARCH=aarch64; fi && \
    mkdir -p /opt/gcc && \
    cd /opt/gcc && \
    wget https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-$ARCH-linux.tar.bz2 && \
    tar xjf gcc-arm-none-eabi-10.3-2021.10-$ARCH-linux.tar.bz2 && \
    rm -rf /opt/gcc/*.tar.bz2

ENV PATH="/opt/gcc/gcc-arm-none-eabi-10.3-2021.10/bin:${PATH}"

RUN pip3 install pyserial
RUN pip3 install inquirer

# Edge Impulse Example: stand-alone inferencing (Sony's Spresense)

This repository runs an exported impulse on the Spresense by Sony development board. See the documentation at [Running your impulse locally (Spresense)](https://docs.edgeimpulse.com/docs/running-your-impulse-spresense).

## Requirements

### Hardware

Purchase Sony's Spresense main board, available [here](https://developer.sony.com/develop/spresense/buy-now).

### Software

This project contains an exported version of the `Sony Spresense SDK` and requires the following tools:

* [Node.js 12](https://nodejs.org/en/download/) or higher.  
* [Python 3](https://www.python.org/download/releases/3.0/).  
* [CMake](https://cmake.org) version 3.12.1 or higher.  
* [GNU Make](https://www.gnu.org/software/make/).  
* [GNU ARM Embedded Toolchain 8-2018-q4-major](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads) - make sure `arm-none-eabi-gcc` is in your PATH.  
* [Edge Impulse CLI](https://docs.edgeimpulse.com/docs/cli-installation).  
    You can install this via npm:
    ```
    $ npm install edge-impulse-cli@latest -g
    ```

## Building the application

1. Build the application by calling `make` in the root directory of the project:  
    ```
    $ make
    ```
1. Connect the board to your computer using USB.  
1. Flash the board:  
    ```
    $ make flash
    ```

### Or build with Docker

1. Build the Docker image:  
    ```
    $ docker build -t spresense-build .
    ```
1. Build the application by running the container as follows:  
    ```
    $ docker run --rm -it -v $PWD:/app:delegated spresense-build /bin/bash -c "make -j"
    ```
1. Flash the board:  
    ```
    $ docker run --rm -it -v $PWD:/app:delegated --privileged spresense-build /bin/bash -c "make flash"
    ```

## Serial connection

Use `screen` or `minicom` to set up a serial connection over USB. Default UART settings are used (115200 baud, 8N1).

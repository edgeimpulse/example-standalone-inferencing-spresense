# Edge Impulse Example: stand-alone inferencing (Sony's Spresense)

This repository runs an exported impulse on the Spresense by Sony development board. See the documentation at [Running your impulse locally (Spresense)](https://docs.edgeimpulse.com/docs/running-your-impulse-spresense).

## Requirements

### Hardware

Purchase Sony's Spresense main board, available [here](https://developer.sony.com/develop/spresense/buy-now).

### Software

This project contains an exported version of the `Sony Spresense SDK` and requires the following tools:

* [Edge Impulse CLI](https://docs.edgeimpulse.com/docs/cli-installation).  
* [CMake](https://cmake.org) version 3.12.1 or higher.  
* [GNU Make](https://www.gnu.org/software/make/).  
* [GNU ARM Embedded Toolchain 8-2018-q4-major](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads) - make sure `arm-none-eabi-gcc` is in your PATH.  

## Building the application

1. Build the application by calling `make` in the root directory of the project:  
    ```
    $ make -j
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
    **Windows**
    ```
    $ docker run --rm -it -v "%cd%":/app spresense-build /bin/bash -c "make -j"
    ```
    **Linux, macOS**
    ```
    $ docker run --rm -it -v $PWD:/app:delegated spresense-build /bin/bash -c "make -j"
    ```
1. Connect the board to your computer using USB. 
1. Flash the board:
    ```
    $ make flash
    ```
    Or if you don't have `make` installed:
    ```
    $ tools/flash_writer.py -s -d -b 115200 -n build/firmware.spk
    ```

## Serial connection

Use `screen` or `minicom` to set up a serial connection over USB. Default UART settings are used (115200 baud, 8N1).

## Troubleshooting

**undefined reference to `_impure_ptr'**

Make sure you build with [GNU ARM Embedded Toolchain 8-2018-q4-major](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads). If you have multiple toolchains installed, you can override the compiler via:

```
$ CC=~/toolchains/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-gcc CXX=~/toolchains/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-g++ make -j
```

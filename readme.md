# itapi

## Introduction

Basic project illustrating baremetal programming of the Raspberry Pi 1 Model B using ARM assembly language.

Includes code for utilisation of system timer, gpio (general purpose input output), mailbox and gpu framebuffer.

## How to use

A makefile is included such that running `make` will build the kernel binary and write it to your SD card for booting on the Raspberry Pi 1 Model B.

To use the makefile, you must initially configure it as follows.

- set INSTALL_DEVICE and INSTALL_PATH in makefile
    - INSTALL_DEVICE points to the SD card device e.g. /dev/sdb1
    - INSTALL_PATH points to the local mount point e.g. /media/robd/bootfs
    
- run `make` from terminal
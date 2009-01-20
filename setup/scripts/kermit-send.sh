#!/bin/bash

kermit -C "set line /dev/ttyS0,set speed 115200,set flow-control rts/cts,set carrier-watch off,set prefixing all,send u-boot.bin,connect"

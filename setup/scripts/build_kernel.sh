#!/bin/bash

# Make sure the cross compiler is set
if [ "$CC_PATH" == '' ]
then
	echo "Cross Compiler not set"
	exit 1
fi

# Make sure we are in the right directory
IN_KERNEL_DIR=`pwd | grep 'kernel'`
if [ "$IN_KERNEL_DIR" == '' ]
	then
	echo "Wrong Directory"
	exit 1
fi

# Make sure mkimage is found
MKIMAGE=`which mkimage`
if [ "$MKIMAGE" == '' ]
	then
	echo "mkimage not in path"
	exit 1
fi



# Determine version of kernel to build
case "$1" in 
	SDP)
	CONFIG_TYPE=omap_3430sdp_android_defconfig
	;;

	LDP)
	CONFIG_TYPE=omap_ldp_android_defconfig
	;;

	*)
	echo $"Usage: $0 {SDP|LDP}"
	exit 1
esac

# Build Kernel
make CROSS_COMPILE=$CC_PATH distclean
make CROSS_COMPILE=$CC_PATH $CONFIG_TYPE
make CROSS_COMPILE=$CC_PATH uImage

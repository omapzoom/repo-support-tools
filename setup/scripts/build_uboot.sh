#!/bin/bash

# Make sure cross compiler is set
if [ "$CC_PATH" == '' ]
then
	echo "Cross Compiler not set"
	exit 1
fi

# MAke sure we are in the right directory
IN_UBOOT_DIR=`pwd | grep 'u-boot'`
if [ "$IN_UBOOT_DIR" == '' ]
then
	echo "Wrong Directory"
	exit 1
fi

# Determine config type for u-boot
case "$1" in
	SDP)
	CONFIG_TYPE=omap3430sdp_config
	;;
	
	LDP)
	CONFIG_TYPE=omap3430labrador_config
	;;

	ZOOM2)
	CONFIG_TYPE=omap3430zoom2_config
	;;

	*)
		echo $"Usage: $0 {SDP|LDP|ZOOM2}"
		exit 1
esac


# Build U-boot
make distclean
make CROSS_COMPILE=$CC_PATH $CONFIG_TYPE
make CROSS_COMPILE=$CC_PATH


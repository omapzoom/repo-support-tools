#!/bin/bash

# Make sure cross compiler is set
if [ "$CC_PATH" == '' ]
then
	echo "Cross Compiler not set"
	exit 1
fi

# Make sure we are in the right directory
IN_XLOADER_DIR=`pwd | grep 'x-loader'`
if [ "$IN_XLOADER_DIR" == '' ]
then
	echo "Wrong Directory"
	exit 1
fi


case "$1" in
	SERIAL)
	CONFIG_TYPE= omap3430labradordownload_config
	TARGET=x-load-serial.bin
	;;

	NAND)
	CONFIG_TYPE=omap3430labrador_config
	TARGET=x-load-serial.bin
	SIGN=true
	;;
	
	*)
	echo $"Usage: $0 {SERIAL|NAND}"
	exit 1
esac	

# Build Serial Version
make distclean
make CROSS_COMPILE=$CC_PATH $CONFIG_TYPE
make CROSS_COMPILE=$CC_PATH
cp x-load.bin ~/bin/$TARGET

if [ "$SIGN" == 'true' ]
then
	omap3430gp-signer.pl x-load-nand.bin ~/bin/x-load-nand-signed.bin
fi

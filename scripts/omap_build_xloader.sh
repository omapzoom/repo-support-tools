#!/bin/bash

BIN_DIR="$HOME/bin"

# Define Quitting Function
function quit {
	echo -e $1
	exit $2
}

# Make sure the cross compiler is set
if [ "$CC_PATH" == '' ]
then
	quit "Cross Compiler not set. Please ensure that \$CC_PATH is set and is of the form '/path/to/cross_compiler/arm-whatever-gnueabi-'" 1
fi

# Make sure we are in the right directory
IN_XLOADER_DIR=`pwd | grep 'x-loader'`
if [ "$IN_XLOADER_DIR" == '' ]
	then
	quit "Wrong Directory. You must be in the X-loader directory" 1
fi

# Determine config type for u-boot
case "$1" in
	SERIAL)
	CONFIG_TYPE=omap3430labradordownload_config
	TARGET=x-load-serial.bin
	;;

	NAND)
	CONFIG_TYPE=omap3430labrador_config
	TARGET=x-load-nand.bin
	SIGN=true
	;;
	
	*)
		quit "Usage: $0 {SERIAL|NAND} [logFile]\n\tIf logFile is not provided the output will be logged\n\tto a file with the current time stamp." 1
esac

# Build U-boot
DIST_CLEAN="CROSS_COMPILE=$CC_PATH distclean"
CONFIG="CROSS_COMPILE=$CC_PATH $CONFIG_TYPE"
BUILD="CROSS_COMPILE=$CC_PATH"

if [ "$2" == '' ]
then
	DT=`date +%Y%m%d_%H%M%S`
	LOG_FILE="build_xloader_${DT}.log"
else
	LOG_FILE="$2"
fi

echo "--------" | tee -a $LOG_FILE 2>&1
echo "Cleaning" | tee -a $LOG_FILE 2>&1
echo "--------" | tee -a $LOG_FILE 2>&1

make $DIST_CLEAN | tee -a $LOG_FILE 2>&1

echo "---------" | tee -a $LOG_FILE 2>&1
echo "Configing" | tee -a $LOG_FILE 2>&1
echo "---------" | tee -a $LOG_FILE 2>&1

make $CONFIG | tee -a $LOG_FILE 2>&1

echo "--------" | tee -a $LOG_FILE 2>&1
echo "Building" | tee -a $LOG_FILE 2>&1
echo "--------" | tee -a $LOG_FILE 2>&1

make $BUILD | tee -a $LOG_FILE 2>&1

if [ $? == 0 ]
then
	quit "\n*** X-loader Build Completed Sucessfully. ***\n" 0
else
	quit "\n*** X-loader Build Failed. ***\n" 1
fi

cp x-load.bin ~/bin/$TARGET

if [ "$SIGN" == 'true' ]
then
	omap3430gp-signer.pl x-load-nand.bin $BIN_DIR/x-load-nand-signed.bin
fi

















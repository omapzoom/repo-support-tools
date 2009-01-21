#!/bin/bash

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
IN_KERNEL_DIR=`pwd | grep 'kernel'`
if [ "$IN_KERNEL_DIR" == '' ]
	then
	quit "Wrong Directory. You must be in the kernel directory" 1
fi

# Make sure mkimage is found
MKIMAGE=`which mkimage`
if [ "$MKIMAGE" == '' ]
	then
	quit "mkimage not in path" 1
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
	quit "Usage: $0 {SDP|LDP} [logFile]\n\tIf logFile is not provided the output will be logged\n\tto a file with the current time stamp." 1
esac

# Build Kernel
DIST_CLEAN="CROSS_COMPILE=$CC_PATH distclean"
CONFIG="CROSS_COMPILE=$CC_PATH $CONFIG_TYPE"
BUILD="CROSS_COMPILE=$CC_PATH uImage"

if [ "$2" == '' ]
then
	DT=`date +%Y%m%d_%H%M%S`
	LOG_FILE="build_kernel_${DT}.log"
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
	quit "\n*** U-Boot Build Completed Sucessfully. ***\n" 0
else
	quit "\n*** U-Boot Build Failed. ***\n" 1
fi



#!/bin/bash
function usage {
    echo Usage:
    echo '     '$0 '[ -disable|-reset ]'
    echo ' -disable : use stub replace the lib'
    echo ' -reset   : reset the old lib'
}
if [ "$1" == "--help" ]; then
    usage
    exit
fi

TOP=`pwd`
FS_PATH=''
LIB_NAME='pvplayer.cfg'
FS_PATH='out/target/product/zoom2/system'

echo "Target File System path = $FS_PATH"
LIB_PATH=$FS_PATH'/etc/'
VENDER_PATH="vendor/ti/zoom2/"
ORIG_LIB_PATH=$LIB_PATH$LIB_NAME'.orig'
STUB_LIB_PATH=$VENDER_PATH$LIB_NAME

function disable_pvcodec {
    if  test ! -d $LIB_PATH ; then
        echo "The path : $LIB_PATH is not a directory"
        exit
    fi
    if [ -e $ORIG_LIB_PATH ]; then
       echo "The lib has already been changed"
       exit
    fi
    echo "==== Replace the lib : $LIB_NAME ===="
    mv $LIB_PATH$LIB_NAME $ORIG_LIB_PATH
    cp $STUB_LIB_PATH $LIB_PATH
}

function reset_pvcodec {
    if [ -e $ORIG_LIB_PATH ]; then
       echo "==== Reset the lib : $LIB_NAME ===="
       cp $ORIG_LIB_PATH $LIB_PATH$LIB_NAME
       rm $ORIG_LIB_PATH
    else
       echo "Can't Reset the lib"
       exit
    fi
}

if [ "$1" == "-reset" ]; then
    reset_pvcodec
else
    disable_pvcodec
fi
exit





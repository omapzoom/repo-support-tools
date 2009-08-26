#!/system/bin/sh
usage() {
    echo Usage:
    echo '     '$0 '[ -disable|-reset ]'
    echo ' -disable : use stub replace the lib'
    echo ' -reset   : reset the old lib'
}

TOP=`pwd`
FS_PATH=''
LIB_NAME='pvplayer.cfg'
FS_PATH='/system'

echo "Target File System path = $FS_PATH"
LIB_PATH=$FS_PATH'/etc/'
VENDER_PATH="/sdcard/"
ORIG_LIB_PATH=$LIB_PATH$LIB_NAME'.orig'
STUB_LIB_PATH=$VENDER_PATH$LIB_NAME

disable_pvcodec() {
    if  test ! -d $LIB_PATH ; then
        echo "The path : $LIB_PATH is not a directory"
        exit
    fi
    if [ -e $ORIG_LIB_PATH ]; then
       echo "The lib has already been changed"
       exit
    fi
    echo ==== Replace the lib : $LIB_NAME ====
    mount -o remount rw /system
    mv $LIB_PATH$LIB_NAME $ORIG_LIB_PATH
    cat $STUB_LIB_PATH > $LIB_PATH$LIB_NAME
}

reset_pvcodec() {
    if [ -e $ORIG_LIB_PATH ]; then
       echo ==== Reset the lib : $LIB_NAME ====
	mount -o remount rw /system
       cat $ORIG_LIB_PATH > $LIB_PATH$LIB_NAME
       rm $ORIG_LIB_PATH
    else
       echo "Can't Reset the lib"
       exit
    fi
}

if [ "$1" = "-reset" ]; then
    reset_pvcodec
elif [ "$1" = "-disable" ]; then
    disable_pvcodec
else
     usage
fi
exit





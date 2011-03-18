#!/bin/bash

# =============================================================================
# Local variables
# =============================================================================

flavor="$1"
fastboot="./fastboot"
android=( gingerbread froyo eclair donut )
params=$#

# =============================================================================
# Functions
# =============================================================================

# Prints script usage
# @ Function: usage
# @ Parameters: none
# @ Return: exit status
usage() {
	cat <<-EOF >&2
	----------------------------------------------
	 Usage:

	 fastboot.sh [flavor]

	 @ flavor: correspond to the Android release:
	           gingerbread, froyo, eclair, donut

	----------------------------------------------
	EOF
	exit 1
}

# Prints a message with a specific format
# @ Function: errmsg
# @ Parameters: <message to display>
# @ Return: exit status
errormsg() {
	messages=( "$@" )
	echo -e ""
	for index in ${!messages[@]}; do
		echo -e "${messages[$index]}" 1>&2
	done
	echo -e ""
	exit 1
}

# Verify if a file exist
# @ Function: findfile
# @ Parameters: <file>
# @ Return: exit status
findfile() {
	file=$1
	if [ "X$file" = "X" ]; then
		errormsg "Error: file name not specified"
	elif [ ! -f $file -a ! -s $file ]; then
		errormsg "Error: $file can not be found" \
			 "The flash process can not be initialized"
	fi
}

# =============================================================================
# pre-run
# =============================================================================

# Verify fastboot program is available
# Verify user permission to run fastboot
# Verify fastboot detects a device, otherwise exit
if [ -f $fastboot ]; then
	fastboot_status=`$fastboot devices 2>&1`
	if [ `echo $fastboot_status | grep -wc "no permissions"` -gt 0 ]; then
		cat <<-EOF >&2
		-------------------------------------------
		 Fastboot requires administrator permissions
		 Please run the script as root or create a
		 fastboot udev rule, e.g:

		 % cat /etc/udev/rules.d/99_android.rules
		   SUBSYSTEM=="usb",
		   SYSFS{idVendor}=="0451"
		   OWNER="<username>"
		   GROUP="adm"
		-------------------------------------------
		EOF
		exit 1
	elif [ "X$fastboot_status" = "X" ]; then
		errormsg "No device detected. Please ensure that" \
			 "fastboot is running on the target device"
	else
		device=`echo $fastboot_status | awk '{print$1}'`
		echo -e "\nFastboot - device detected: $device\n"
	fi
else
	errormsg "Error: fastboot is not available at $fastboot"
fi

# =============================================================================
# Main
# =============================================================================

# Verify Script usage and validate all parameters
if [ $params -ne 1 ]; then
	usage
fi

if [ ! `echo ${android[@]} | grep -wc $flavor` -eq 1 ]; then
	echo -e "\nERROR: First parameter introduced is invalid\n" 1>&2
	usage
fi

# Verify that all the files required for the fastboot flas process
# are available

findfile "./MLO"
findfile "./u-boot.bin"
findfile "./boot.img"
findfile "./system.img"
findfile "./cache.img"

case $flavor in
"gingerbread")
	findfile "./userdata.img"
	;;
"froyo" | "eclair" | "donut")
	findfile "./data.img"
	findfile "./mbr.bin"
	findfile "./env.txt"
	;;
esac

# Start fastboot flash process

case $flavor in
"gingerbread")
	#Format the gpt on storage device
	echo "Flashing Android $flavor release"
	#TI specific boot loader flashing
	$fastboot flash xloader ./MLO
	$fastboot flash bootloader ./u-boot.bin
	$fastboot reboot-bootloader
	sleep 5
	$fastboot oem format
	#Generic Android partitions
	$fastboot flash boot ./boot.img
	$fastboot flash system ./system.img
	# Gingerbread specific
	$fastboot flash userdata ./userdata.img
	# Generic Android partitions
	$fastboot flash cache ./cache.img
	;;
"froyo" | "eclair" | "donut")
	echo "Flashing Android $flavor release"
	$fastboot flash ptable ./mbr.bin
	$fastboot flash environment ./env.txt
	$fastboot flash xloader ./MLO
	$fastboot flash bootloader ./u-boot.bin
	# Generic Android partitions
	$fastboot flash boot ./boot.img
	$fastboot flash system ./system.img
	# Froyo specific
	$fastboot flash userdata ./data.img
	# Generic Android partitions
	$fastboot flash cache ./cache.img
	;;
*)
	usage
	;;
esac

exit 0

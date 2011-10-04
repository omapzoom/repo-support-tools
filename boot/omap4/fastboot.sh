#!/bin/bash

# =============================================================================
# Local variables
# =============================================================================

flavor="$1"
fastboot="./fastboot"
android=( honeycomb gingerbread froyo eclair donut )
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
	           * honeycomb
	           * gingerbread
	           * froyo
	           * eclair
	           * donut

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
	echo -e "\nERROR: Number of parameters is invalid\n" 1>&2
	usage
fi

if [ ! `echo ${android[@]} | grep -wc $flavor` -eq 1 ]; then
	echo -e "\nERROR: First parameter introduced is invalid\n" 1>&2
	usage
fi

product=`$fastboot getvar product 2>&1 | grep product | awk '{print$2}'`
cputype=`$fastboot getvar secure 2>&1  | grep secure  | awk '{print$2}'`
cpurev=`$fastboot getvar cpurev 2>&1   | grep cpurev  | awk '{print$2}'`

# Panda board can not be flashed using fastboot

if [ $product = "PANDA" ]; then
	errormsg "Panda board can not be flashed using fastboot"
fi

# Backwards Compatibility for older bootloader versions

if [ $product = "SDP4" ]; then
	product="Blaze"
fi

# Provide the correct binaries according to the platform

# TODO: provide multi-platform binaries in one package
# What is common among platforms??
# uboot="${product}_${cputype}_${cpurev}_uboot"
# systemimg="${product}_${cputype}_${cpurev}_systemimg"
# userdataimg="${product}_${cputype}_${cpurev}_userdataimg"
# cacheimg="${product}_${cputype}_${cpurev}_cacheimg"
# mbr="${product}_${cputype}_${cpurev}_mbr"
# env="${product}_${cputype}_${cpurev}_env"
# dataimg="${product}_${cputype}_${cpurev}_dataimg"
# bootimg="${product}_${cputype}_${cpurev}_bootimg"

xloader="${product}_${cputype}_${cpurev}_MLO"
uboot="./u-boot.bin"
systemimg="./system.img"
userdataimg="./userdata.img"
cacheimg="./cache.img"
mbr="./mrb.bin"
env="./env.txt"
dataimg="./data.img"
bootimg="./boot.img"

# Verify that all the files required for the fastboot flash
# process are available

findfile $xloader
findfile $uboot
findfile $bootimg
findfile $systemimg
findfile $cacheimg

case $flavor in
"gingerbread" | "honeycomb")
	findfile $userdataimg
	;;
"froyo" | "eclair" | "donut")
	findfile $dataimg
	findfile $mbr
	findfile $env
	;;
esac

# Start fastboot flash process

case $flavor in
"gingerbread" | "honeycomb")
	#Format the gpt on storage device
	echo -e "\nSystem: $product $cputype $cpurev"
	echo -e "Flashing Android $flavor release\n"
	#TI specific boot loader flashing
	$fastboot flash xloader $xloader
	$fastboot flash bootloader $uboot
	$fastboot reboot-bootloader
	sleep 5
	$fastboot oem format
	#Generic Android partitions
	$fastboot flash boot $bootimg
	$fastboot flash system $systemimg
	# Gingerbread specific
	$fastboot flash userdata $userdataimg
	# Generic Android partitions
	$fastboot flash cache $cacheimg
	;;
"froyo" | "eclair" | "donut")
	echo -e "\nSystem: $product $cputype $cpurev"
	echo -e "Flashing Android $flavor release\n"
	$fastboot flash ptable $mbr
	$fastboot flash environment $env
	$fastboot flash xloader $xloader
	$fastboot flash bootloader $uboot
	# Generic Android partitions
	$fastboot flash boot $bootimg
	$fastboot flash system $systemimg
	# Froyo specific
	$fastboot flash userdata $dataimg
	# Generic Android partitions
	$fastboot flash cache $cacheimg
	;;
*)
	echo -e "\nERROR: Flavor flash procedure not supported\n" 1>&2
	usage
	;;
esac

exit 0

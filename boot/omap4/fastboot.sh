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

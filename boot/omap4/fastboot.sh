#!/bin/bash
if [ "$1" != "froyo" ] ; then
  #Format the gpt on storage device
  echo "Flashing Android Gingerbread release"
  #TI specific boot loader flashing
  ./fastboot flash xloader ./MLO
  ./fastboot flash bootloader ./u-boot.bin
  ./fastboot reboot-bootloader
sleep 5
  ./fastboot oem format

else
  echo "Flashing Android Froyo release"
  ./fastboot flash ptable ./mbr.bin
  ./fastboot flash environment ./env.txt
  ./fastboot flash xloader ./MLO
  ./fastboot flash bootloader ./u-boot.bin
fi

#Generic Android partitions
./fastboot flash boot ./boot.img
./fastboot flash system ./system.img
if [ "$1" != "froyo" ] ; then
  ./fastboot flash userdata ./userdata.img
else
  ./fastboot flash userdata ./data.img
fi
./fastboot flash cache ./cache.img

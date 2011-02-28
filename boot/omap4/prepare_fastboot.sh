echo "#####################################################################"
echo ######################################################################
echo This script should be run specifically when bootloader gets upgraded
echo Note: If bootloader is not updated since last time you flashed it,
echo "      this step is optional (it won't harm either)"
echo ######################################################################
echo "#####################################################################"
echo ######################################################################
echo Now ERASING all the fastboot partitions
echo #######################################################################

if [ "$1" != "froyo" ] ; then
  #Format the gpt on storage device
  echo "Erasing Android Gingerbread release"
else
  echo "Erasing Android Froyo release"
  ./fastboot erase ptable
  ./fastboot erase environment
  ./fastboot erase xloader
  ./fastboot erase bootloader
  ./fastboot erase boot
  ./fastboot erase system
  ./fastboot erase userdata
  ./fastboot erase cache
fi
echo "#####################################################################"
echo ######################################################################
echo "** COMPLETED ERASING fastboot partitions **"
echo ######################################################################
echo NOW FLASHING The bootloader ....
echo ######################################################################
echo "#####################################################################"
if [ "$1" != "froyo" ] ; then
  echo "Format the gpt on storage device"
else
  ./fastboot flash ptable ./mbr.bin
fi
./fastboot flash xloader ./MLO
./fastboot flash bootloader ./u-boot.bin
echo ######################################################################
echo "#####################################################################"
echo ######################################################################
echo Power Cycle the Board now and restart fastboot client on board
echo ######################################################################
echo You can now execute fastboot.sh script now
echo ######################################################################
echo "#####################################################################"

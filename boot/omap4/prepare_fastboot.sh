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
echo "#####################################################################"
./fastboot erase ptable
./fastboot erase xloader
./fastboot erase bootloader
./fastboot erase environment
./fastboot erase boot
./fastboot erase system
./fastboot erase userdata
./fastboot erase cache
echo "#####################################################################"
echo ######################################################################
echo "** COMPLETED ERASING fastboot partitions **"
echo ######################################################################
echo NOW FLASHING The bootloader ....
echo ######################################################################
echo "#####################################################################"
./fastboot flash ptable ./mbr.bin
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

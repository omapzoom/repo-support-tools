./fastboot flash ptable ./mbr.bin
./fastboot flash xloader ./MLO
./fastboot flash bootloader ./u-boot.bin
./fastboot flash environment ./env.txt
./fastboot flash boot ./boot.img
./fastboot flash system ./system.img
./fastboot flash userdata ./data.img
./fastboot flash cache ./cache.img

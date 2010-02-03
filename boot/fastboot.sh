sudo ./fastboot flash xloader ./MLO
sudo ./fastboot flash bootloader ./u-boot.bin
sudo ./fastboot flash environment ./env.txt
sudo ./fastboot flash kernel ./uMulti-2
sudo ./fastboot flash system ./system.img
sudo ./fastboot flash userdata ./userdata.img
sudo ./fastboot erase cache
sudo ./fastboot reboot


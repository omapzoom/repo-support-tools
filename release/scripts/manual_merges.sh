# Error codes for the script
E_NO_DIRECTORY=30

echo "********************"
echo "Adding manual merges"
echo "********************"

if [ ! -d .repo ]
then
   echo "You are not in the directory where you ran repo init. "
   echo "Please rerun this script from that location."
   return $E_NO_DIRECTORY
fi

MYDROID=`pwd`


# *******************************************************************************
# L25.10
# Manual Merges to be done on top of manifest
#
# This list is based on the list from the kernel team -- no other merges are
# currently being made.  
#
# *******************************************************************************
# Pulling in the following commits from kernel:
#
#
# Google Gerrit Changes:
# 10588: Zoom2 LCD TV panel driver supporting DSS2 device model
# 10589: Zoom2_defconfig supports 1 FB node 2 Video nodes by default.
# 10597: DSS2: Allocate only needed memory and align to page size
# 10618: Enable JFFS2 FS support in zoom2_defconfig.
#
 
 
# *******************************************************************************
# commands to run manually

cd $MYDROID/kernel/2.6.29
echo "Adding patch 10588"
git pull git://android.git.kernel.org/kernel/omap refs/changes/88/10558/1
echo "Adding patch 10589"
git pull git://android.git.kernel.org/kernel/omap refs/changes/59/10559/1
echo "Adding patch 10597"
git pull git://android.git.kernel.org/kernel/omap refs/changes/97/10597/1
echo "Adding patch 10618"
git pull git://android.git.kernel.org/kernel/omap refs/changes/18/10618/1

cd $MYDROID
return 0


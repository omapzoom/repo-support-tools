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
# 9839: Increase NAND partition sizes for Kernel and System
# 10618: Enable JFFS2 FS support in zoom2_defconfig.
# 10636: omap iommu: add MPU_BRIDGE_IOMMU for tidspbridge migration
# 10649: OMAP3: EHCI: use clock framework to program DPLL5 clocks
# 10664: Fix OHCI PRCM interrupt crash on resume/remote-wakeup
# 10525: [rfkill]: wl127x-rfkill: Add fm rfkill entry to wl127x-rfkill driver
# 10547: [ARM]: omap2: zoom2: Add 161 as FM Enable GPIO to board-zoom2 Signed-off-by: Pavan Savoy <pavan_savoy@ti.com>
# 10524: rfkill: Add new rfkill type RFKILL_TYPE_FM Signed-off-by: Pavan Savoy <pavan_savoy@ti.com>
# 10677: omap_vout remove remap_pfn_range call from mmap and add vm_insert_page
# 10678: omap_vout: Enable rotation set after reqbuf ioctl
# 10679: omap_vout: fix to allow queue reset in streamoff
# 10680: V4L2: omap_vout Incremented VID_MAX_HEIGHT
# 10681: omap34xxcam: Allow upscaling cases in size negotiation
#
# *******************************************************************************
# commands to run manually

echo "Kernel patches"
cd $MYDROID/kernel/android-2.6.29
echo "   Adding patch 9839"
git pull git://android.git.kernel.org/kernel/omap refs/changes/39/9839/1
echo "   Adding patch 10618"
git pull git://android.git.kernel.org/kernel/omap refs/changes/18/10618/1
echo "   Adding patch 10636"
git pull git://android.git.kernel.org/kernel/omap refs/changes/36/10636/1
echo "   Adding patch 10649"
git pull git://android.git.kernel.org/kernel/omap refs/changes/49/10649/1
echo "   Adding patch 10664"
git pull git://android.git.kernel.org/kernel/omap refs/changes/64/10664/2
echo "   Adding patch 10547"
git pull git://android.git.kernel.org/kernel/omap refs/changes/47/10547/2
echo "   Adding patch 10524"
git pull git://android.git.kernel.org/kernel/omap refs/changes/24/10524/1
echo "   Adding patch 10677 -- patch for MM"
git pull git://android.git.kernel.org/kernel/omap refs/changes/77/10677/1
echo "   Adding patch 10678 -- patch for MM"
git pull git://android.git.kernel.org/kernel/omap refs/changes/78/10678/1
echo "   Adding patch 10679 -- patch for MM"
git pull git://android.git.kernel.org/kernel/omap refs/changes/79/10679/1
echo "   Adding patch 10680 -- patch for MM"
git pull git://android.git.kernel.org/kernel/omap refs/changes/80/10680/1
echo "   Adding patch 10681 -- patch for MM"
git pull git://android.git.kernel.org/kernel/omap refs/changes/81/10681/1


#echo
echo "   Pulling Audio Feature Tree"
git pull git://dev.omapzoom.org/pub/scm/misael/android-2.6.29-audio.git audio-2.6.29-25.10-rc1

#echo
echo "Bridge Patches"
echo "   Adding bridge driver release patches from android branch"
git pull git://dev.omapzoom.org/pub/scm/tidspbridge/kernel-dspbridge.git bridge-2.6.29-25.10-P1

echo
echo "Multimedia Patches"
echo "   Adding 9849"
cd $MYDROID/external/skia
git pull git://android.git.kernel.org/platform/external/skia refs/changes/49/9849/1

#echo "   Adding 10030"
#cd $MYDROID/frameworks/base 
#git pull git://android.git.kernel.org/platform/frameworks/base refs/changes/30/10030/1

cd $MYDROID
return 0


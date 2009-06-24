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
# L25.9RC2
# Manual Merges to be done on top of manifest
#
# This list is based on the list from L25.9. 
#
# *******************************************************************************
# Pulling in the following commits from kernel:
#
#
# Google Gerrit Changes:
# 9671: Added support for raw10 format. (from L25.8)
# 9887: Battery Service fix for "power off" at boot up (from L25.8)
# 9888: overlay.h - Added new APIs (from L25.8)
# 9889: Added support for new Overlay APIs. (from L25.8)
# 9890: Overlay - rearranged destruction of overlay components (from L25.8)
# 9895: CameraService: Recreate overlay only if height and width has changed. (from L25.8)
# 9899: overlay.h - Added a new API setAttributes to data side
# 9900: Overlay: Added support for new overlay API setAttributes (from L25.8)
# 9903: Initialize mVisibilityChanged to fix a bug (from L25.8)
# 9958: Clearing FrameBuffer when Overlay is in use. (from L25.8)
# 10011: soundrecorder setting options (from L25.8)
# 10030: Adding wb-amr and aac encoder types (from L25.8)
# 10031: Adding options to select between nb-amr, wb-amr, and aac encoder types (from L25.8)
# 10041: Increase teh number of shared libraries (.so) that can be opened. (from L25.8)
# 10450: Making the audio buffer timeout dynamic  (L25.9RC2)
# 10453: Enable additional plugins. Enable inlining. (L25.9RC2)
# 10483: Added more options to the Camcorder Menu (L25.9RC2)
#
#
# OMAPZoom Gerrit Ids:
# 342: overlay: Added new APIs. (from L25.8)
# 343: Overlay: Added support for new data API setAttributes (from L25.8)
# 411: Migration to OpenCore 2.04 (L25.9RC2)
# 433: Changing range of audio encoder types to reflect the addition of AAC and WB-AMR types. (L25.9RC2)
# 471:  symlinking /lib to /system/lib - BT looks for /lib/firmware  modified:   init.omapzoom2.rc (L25.9RC2)
# 483: Merge commit 'refs/changes/11/411/1' of ssh://sanuradha@review.omapzoom.org:29418/platform/hardware/ti/omap3 into anu_branch_jun13 (L25.9RC2)
# 484: VIdeo Playback: FPS measurement (L25.9RC2)
#
 
 
# *******************************************************************************
# commands to run manually

cd $MYDROID/bionic
echo "Adding patch 9671"
git pull git://android.git.kernel.org/platform/bionic refs/changes/71/9671/1

cd $MYDROID/hardware/libhardware
echo "Adding patch 9888"
git pull git://android.git.kernel.org/platform/hardware/libhardware refs/changes/88/9888/1

cd $MYDROID/frameworks/base
echo "Adding patch 9889"
git pull git://android.git.kernel.org/platform/frameworks/base refs/changes/89/9889/1
echo "Adding patch 9890"
git pull git://android.git.kernel.org/platform/frameworks/base refs/changes/90/9890/1
echo "Adding patch 9895"
git pull git://android.git.kernel.org/platform/frameworks/base refs/changes/95/9895/1
echo "Adding patch 10450"
git pull git://android.git.kernel.org/platform/frameworks/base refs/changes/50/10450/1


cd $MYDROID/hardware/libhardware
echo "Adding patch 9899"
git pull git://android.git.kernel.org/platform/hardware/libhardware refs/changes/99/9899/1

cd $MYDROID/frameworks/base
echo "Adding patch 9900"
git pull git://android.git.kernel.org/platform/frameworks/base refs/changes/00/9900/1
echo "Adding patch 9903"
git pull git://android.git.kernel.org/platform/frameworks/base refs/changes/03/9903/1
echo "Adding patch 9887"
git pull git://android.git.kernel.org/platform/frameworks/base refs/changes/87/9887/1
echo "Adding patch 9958"
git pull git://android.git.kernel.org/platform/frameworks/base refs/changes/58/9958/1
echo "Adding patch 10030"
git pull git://android.git.kernel.org/platform/frameworks/base refs/changes/30/10030/1

cd $MYDROID/packages/apps/SoundRecorder
echo "Adding patch 10011"
git pull git://android.git.kernel.org/platform/packages/apps/SoundRecorder refs/changes/11/10011/1
echo "Adding patch 10031"
git pull git://android.git.kernel.org/platform/packages/apps/SoundRecorder refs/changes/31/10031/1

cd $MYDROID/packages/apps/Camera
echo "Adding patch 10483"
git pull git://android.git.kernel.org/platform/packages/apps/Camera refs/changes/83/10483/1

cd $MYDROID/bionic
echo "Adding patch 10041"
git pull git://android.git.kernel.org/platform/bionic refs/changes/41/10041/1

cd $MYDROID/external/alsa-lib
echo "Adding patch 10453"
git pull git://android.git.kernel.org/platform/external/alsa-lib refs/changes/53/10453/1

cd $MYDROID/vendor/ti/zoom2
echo "Adding patch 471"
git pull git://git.omapzoom.org/platform/vendor/ti/zoom2 refs/changes/71/471/1

cd $MYDROID/hardware/ti/omap3
echo "Adding patch 342"
git pull git://git.omapzoom.org/platform/hardware/ti/omap3 refs/changes/42/342/1
echo "Adding patch 343"
git pull git://git.omapzoom.org/platform/hardware/ti/omap3 refs/changes/43/343/1
echo "Adding patch 411 (dependent on 9888 & 9899)"
git pull git://git.omapzoom.org/platform/hardware/ti/omap3 refs/changes/11/411/1
echo "Adding patch 483 (dependent on 411)"
git pull git://git.omapzoom.org/platform/hardware/ti/omap3 refs/changes/83/483/1
echo "Adding patch 484 (dependent on 483)"
git pull git://git.omapzoom.org/platform/hardware/ti/omap3 refs/changes/84/484/1

cd $MYDROID/external/opencore
echo "Adding patch 484 (dependent on 10030)"
git pull git://git.omapzoom.org/repo/android/platform/external/opencore refs/changes/33/433/1

cd $MYDROID
return 0


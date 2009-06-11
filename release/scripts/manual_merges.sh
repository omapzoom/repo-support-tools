# *******************************************************************************
# from L25.8
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
# 9889: Added support for new Overlay APIs. (from L25.8)
# 9900: Overlay: Added support for new overlay API setAttributes (from L25.8)
# 9903: Initialize mVisibilityChanged to fix a bug (from L25.8)
# 9958: Clearing FrameBuffer when Overlay is in use. (from L25.8)
# 10011: soundrecorder setting options (from L25.8)
# 10025: Added new menu to Camera App (from L25.8)
# 10030: Adding wb-amr and aac encoder types (from L25.8)
# 10031: Adding options to select between nb-amr, wb-amr, and aac encoder types (from L25.8)
# 10041: Increase teh number of shared libraries (.so) that can be opened. (from L25.8)
# 10042: Supress Audio recording in camcorder. (from L25.8)
#
#
# OMAPZoom Gerrit Ids:
# 342: overlay: Added new APIs. (from L25.8)
# 343: Overlay: Added support for new data API setAttributes (from L25.8)
 
 
 
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
echo "Adding patch 10025"
git pull git://android.git.kernel.org/platform/packages/apps/Camera refs/changes/25/10025/1
echo "Adding patch 10042"
git pull git://android.git.kernel.org/platform/packages/apps/Camera refs/changes/42/10042/1

cd $MYDROID/bionic
echo "Adding patch 10041"
git pull git://android.git.kernel.org/platform/bionic refs/changes/41/10041/1

cd $MYDROID/hardware/ti/omap3
echo "Adding patch 342"
git pull git://git.omapzoom.org/platform/hardware/ti/omap3 refs/changes/42/342/1
echo "Adding patch 343"
git pull git://git.omapzoom.org/platform/hardware/ti/omap3 refs/changes/43/343/1

cd $MYDROID

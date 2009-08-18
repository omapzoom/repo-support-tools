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


# ******************************************************************************
# L25.11
# Manual Merges to be done on top of manifest
#
# This file is pulling in changes for camera.  It is expect that this file
# will only be used occasionally for releases past L25.11. 
#
# ******************************************************************************
# Please note the /packages/apps/Camera package has been 
# reset back to commit ID:  5de4e421e17f1c2ed35fa1ccf8777838e884f66b -- this
# has been done automatically with the manifest.  You do not need to do this
# step.  
# The following commits have been pulled from the review.omapzoom.org site:
#
# 702: Remove references to get getThumbnail
# 556: camera options
# 620: no-audio option
# 705: Merge commit 'refs/changes/56/556/1' of ssh://sanuradha@review.omapzoom.org:29418/platform/packages/apps/Camera into HEAD
# 706: Merge commit 'refs/changes/20/620/1' of ssh://sanuradha@review.omapzoom.org:29418/platform/packages/apps/Camera into HEAD
# 707: Added permissions for Audio Record
#
# *******************************************************************************

echo "Camera patches"
cd $MYDROID/packages/apps/Camera
echo "   Adding patch 702"
git pull git://git.omapzoom.org/platform/packages/apps/Camera refs/changes/02/702/1
echo "   Adding patch 556"
git pull git://git.omapzoom.org/platform/packages/apps/Camera refs/changes/56/556/1
echo "   Adding patch 620"
git pull git://git.omapzoom.org/platform/packages/apps/Camera refs/changes/20/620/1
echo "   Adding patch 705 "
git pull git://git.omapzoom.org/platform/packages/apps/Camera refs/changes/05/705/1
echo "   Adding patch 706 "
git pull git://git.omapzoom.org/platform/packages/apps/Camera refs/changes/06/706/1
echo "   Adding patch 707 "
git pull git://git.omapzoom.org/platform/packages/apps/Camera refs/changes/07/707/1
cd $MYDROID
return 0


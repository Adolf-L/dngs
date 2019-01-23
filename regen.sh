#!/bin/sh

#rm -rf DNGPS.xcworkspace Pods Podfile.lock
echo "start reinstall========== "
env SRC_PROJECTS=${srcPrjs} PODFILE_TYPE=development pod install --no-repo-update
echo "opening workspace========== "
open DNGPS.xcworkspace

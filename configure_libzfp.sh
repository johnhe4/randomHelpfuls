#!/bin/bash

# This is a helper script to configure and build libzfp.
# Get the code then run this script:
#   git clone https://github.com/LLNL/zfp.git

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/zfp

# I installed the dependcies manually, letting grpc build only itself
# Feature selection, each one beginning with '-D' because it's CMAKE
FEATURES=" \
"

# Release or Debug?
BUILD_TYPE="-DCMAKE_BUILD_TYPE=Release"

# iOS build? Leave empty if not
PLATFORM="iOS"

########## END USER EDIT SECTION #############

BUILD_FOR=""
if [ "$PLATFORM" = "iOS" ]; then
   BUILD_FOR="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"

   FEATURES="$FEATURES \
   -DBUILD_SHARED_LIBS=OFF \
   -DBUILD_TESTING=OFF \
   -DBUILD_UTILITIES=OFF
   -DCMAKE_C_FLAGS=\"-fembed-bitcode\" \
   -DCMAKE_CXX_FLAGS=\"-fembed-bitcode\" \
   "
fi

# Let's begin. First, enter the new directory
originalDir=`pwd`
cd $srcDir

# Out-of-tree build
mkdir -p build
cd build 

# Run the configure script
cmake .. $BUILD_FOR $BUILD_TYPE $OPEN_SSL $FEATURES

if [ "$PLATFORM" = "iOS" ]; then
   # Use Xcode to make and install
   xcodebuild \
   -configuration Release \
   -target zfp \
   CODE_SIGN_IDENTITY="" \
   CODE_SIGNING_REQUIRED=NO
else
   sudo make install
fi

# Finally, return to the original directory
cd $originalDir

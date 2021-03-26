#!/bin/bash

# This is a helper script to configure and build libzqm.
# Get the code then run this script:
#   git clone https://github.com/zeromq/libzmq.git

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/libzmq

# I installed the dependcies manually, letting grpc build only itself
# Feature selection, each one beginning with '-D' because it's CMAKE
FEATURES=" \
-DENABLE_DRAFTS=ON \

"

# Release or Debug?
BUILD_TYPE="-DCMAKE_BUILD_TYPE=Release"

# iOS build? Leave empty if not
PLATFORM="iOS"

########## END USER EDIT SECTION #############

BUILD_FOR=""
OPEN_SSL=""
if [ "$PLATFORM" = "iOS" ]; then
   BUILD_FOR="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"

   FEATURES="$FEATURES \
   -DZMQ_BUILD_FRAMEWORK=ON \
   -DBUILD_SHARED=OFF \
   -DBUILD_TESTS=OFF \
   -DZMQ_BUILD_TESTS=OFF
   -DWITH_DOCS=OFF \
   -DWITH_LIBSODIUM=OFF \
   -DWITH_PERF_TOOL=OFF \
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
   -target libzmq-static \
   CODE_SIGN_IDENTITY="" \
   CODE_SIGNING_REQUIRED=NO
else
   sudo make install
fi

# Finally, return to the original directory
cd $originalDir

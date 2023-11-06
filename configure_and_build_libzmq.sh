#!/bin/bash

# This is a helper script to configure and build libzmq.
#   git clone https://github.com/zeromq/libzmq.git

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/libzmq

# Build type
#  Debug
#  Release
#  MinSizeRel
BUILD_TYPE=MinSizeRel

# Minimum iOS version (if applicable)
MIN_IOS=15.0

########## END USER EDIT SECTION #############

if [ $# -lt 2 ]; then
   echo " <this_script>.sh host arch prefix"
   echo ""
   echo " host (required):"
   echo "   macos"
   echo "   macoscatalyst"
   echo "   iphoneos"
   echo "   iphonesimulator"
   echo "   xros"
   echo "   xrsimulator"
   echo ""
   echo " arch (required):"
   echo "   x86_64"
   echo "   arm64"
   echo ""
   echo " prefix (default: /usr/local/{host}_{arch})"
fi
BUILD_FOR=$1
ARCH=$2
INSTALL_PREFIX=$3
if [ -z "$INSTALL_PREFIX" ]; then
   INSTALL_PREFIX="/usr/local/${BUILD_FOR}_$ARCH"
fi

# I would love to use zeromq websockets, but that implementation depends on GnuTLS instead of openssl.
# GnuTLS has the LGPL library and that's pretty much a non-starter for me.
OPTIONS=" \
-DZMQ_BUILD_FRAMEWORK=OFF \
-DBUILD_SHARED=OFF \
-DBUILD_TESTS=OFF \
-DZMQ_BUILD_TESTS=OFF \
-DWITH_DOCS=OFF \
-DWITH_LIBSODIUM=OFF \
-DWITH_LIBBSD=OFF \
-DENABLE_CURVE=OFF \
-DENABLE_WS=OFF \
"

if [ -n "$INSTALL_PREFIX" ]; then
   OPTIONS="$OPTIONS -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX"
fi

BUILD_CMD="make -j16"
if [ "$BUILD_FOR" = "iphoneos" ] || [ "$BUILD_FOR" = "iphonesimulator" ] || [ "$BUILD_FOR" = "macoscatalyst" ] || [ "$BUILD_FOR" = "xros" ] || [ "$BUILD_FOR" = "xrsimulator" ]; then
   XCODE_DEV="$(xcode-select -p)"
   if [ "$BUILD_FOR" = "iphoneos" ]; then
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS -DCMAKE_OSX_ARCHITECTURES=$ARCH"
   elif [ "$BUILD_FOR" = "iphonesimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS -DCMAKE_OSX_ARCHITECTURES=$ARCH -DCMAKE_OSX_SYSROOT=$SYSROOT"
   elif [ "$BUILD_FOR" = "macoscatalyst" ]; then
      echo NOT IMPLEMENTED
   elif [ "$BUILD_FOR" = "xros" ]; then
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=visionOS -DCMAKE_OSX_ARCHITECTURES=$ARCH"
   elif [ "$BUILD_FOR" = "xrsimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/XRSimulator.platform/Developer/SDKs/XRSimulator.sdk
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=visionOS -DCMAKE_OSX_ARCHITECTURES=$ARCH -DCMAKE_OSX_SYSROOT=$SYSROOT"
   fi
elif [ "$BUILD_FOR" = "android" ]; then
   OPTIONS="-DCMAKE_SYSTEM_NAME=Android -DCMAKE_SYSTEM_VERSION=32 -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a -DCMAKE_PREFIX_PATH=/usr/local"
elif [ "$BUILD_FOR" = "macos" ]; then
   OPTIONS="$OPTIONS -DCMAKE_OSX_ARCHITECTURES=$ARCH"
else
   OPTIONS="$OPTIONS"
fi

# Let's begin.
originalDir=`pwd`
cd $srcDir
mkdir -p build
cd build

# Start from scratch
rm -f CMakeCache.txt

# Run the configure script
cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE $OPTIONS

# Build
$BUILD_CMD
sudo make install

# Finally, return to the original directory
cd $originalDir

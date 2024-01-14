#!/bin/bash

# This is a helper script to configure and build boringssl.
#   git clone https://github.com:google/boringssl.git
# Requires `go` to be installed

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/boringssl

# Build type
#  Debug
#  Release
#  MinSizeRel
BUILD_TYPE=MinSizeRel

# Minimum iOS version (if applicable)
MIN_IOS=15.0

# Minimum Android SDK version (if applicable)
ANDROID_SDK_VERSION=32

########## END USER EDIT SECTION #############

if [ $# -lt 2 ]; then
   echo " <this_script>.sh host arch prefix"
   echo ""
   echo " host (required):"
   echo "   android"
   echo ""
   echo " arch (required):"
   echo "   x86_64"
   echo "   arm64"
   echo ""
   echo " prefix (default: /usr/local/{host}_{arch})"
   exit -1
fi
BUILD_FOR=$1
ARCH=$2
INSTALL_PREFIX=$3
if [ -z "$INSTALL_PREFIX" ]; then
   INSTALL_PREFIX="/usr/local/${BUILD_FOR}_$ARCH"
fi

OPTIONS=""

if [ -n "$INSTALL_PREFIX" ]; then
   OPTIONS="$OPTIONS -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX"
fi

BUILD_CMD="make -j16"
CONFIGURE_CMD="cmake .."
if [ "$BUILD_FOR" = "android" ]; then
   if [ "$ARCH" = "arm64" ]; then
      OPTIONS="$OPTIONS -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a"
   else
      OPTIONS="$OPTIONS -DCMAKE_ANDROID_ARCH_ABI=x86_64"
   fi
   OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=Android -DCMAKE_SYSTEM_VERSION=$ANDROID_SDK_VERSION"
fi

# Let's begin.
originalDir=`pwd`
cd $srcDir
mkdir -p build
cd build

# Start from scratch
rm -f CMakeCache.txt

# Run the configure script
$CONFIGURE_CMD -DCMAKE_BUILD_TYPE=$BUILD_TYPE $OPTIONS

# Build
$BUILD_CMD
sudo make install

# Finally, return to the original directory
cd $originalDir

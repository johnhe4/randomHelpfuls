#!/bin/bash

# This is a helper script to configure and build libyaml.
#   git clone https://github.com/yaml/libyaml.git

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/libyaml

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

OPTIONS="--enable-shared=no"

if [ -n "$INSTALL_PREFIX" ]; then
   OPTIONS="$OPTIONS --prefix=$INSTALL_PREFIX"
fi

BUILD_CMD="make -j"
if [ "$BUILD_FOR" = "iphoneos" ] || [ "$BUILD_FOR" = "iphonesimulator" ] || [ "$BUILD_FOR" = "macoscatalyst" ] || [ "$BUILD_FOR" = "xros" ] || [ "$BUILD_FOR" = "xrsimulator" ]; then
   XCODE_DEV="$(xcode-select -p)"
   export DEVROOT="$XCODE_DEV/Toolchains/XcodeDefault.xctoolchain"
   export PATH="$DEVROOT/usr/bin/:$PATH"
   if [ "$BUILD_FOR" = "iphoneos" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
      CFLAGS="-target $ARCH-apple-ios$MIN_IOS"
      OPTIONS="$OPTIONS --host=$ARCH-apple-ios"
   elif [ "$BUILD_FOR" = "iphonesimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
      OPTIONS="$OPTIONS --host=$ARCH-apple-darwin"
   elif [ "$BUILD_FOR" = "macoscatalyst" ]; then
      SYSROOT=$XCODE_DEV/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
      CFLAGS="-target $ARCH-apple-ios15.0-macabi"
      OPTIONS="$OPTIONS"
   elif [ "$BUILD_FOR" = "xros" ]; then
      SYSROOT=$XCODE_DEV/Platforms/XROS.platform/Developer/SDKs/XROS.sdk
      CFLAGS="-target $ARCH-apple-xros"
      OPTIONS="$OPTIONS --host=$ARCH-apple-ios"
   elif [ "$BUILD_FOR" = "xrsimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/XRSimulator.platform/Developer/SDKs/XRSimulator.sdk
      OPTIONS="$OPTIONS --host=$ARCH-apple-darwin"
   fi
   CFLAGS="$CFLAGS -arch $ARCH -Os -isysroot $SYSROOT"
   LDFLAGS="-arch $ARCH -isysroot $SYSROOT"
   echo "Building for $BUILD_FOR on $ARCH (sysroot=$SYSROOT)"
   OPTIONS="$OPTIONS --disable-unix-sockets"
elif [ "$BUILD_FOR" = "android" ]; then
   OPTIONS="\
-DCMAKE_SYSTEM_NAME=Android \
-DCMAKE_SYSTEM_VERSION=32 \
-DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
-DCMAKE_PREFIX_PATH=/usr/local \
"
elif [ "$BUILD_FOR" = "macos" ]; then
   # XCODE_DEV="$(xcode-select -p)"
   # export DEVROOT="$XCODE_DEV/Toolchains/XcodeDefault.xctoolchain"
   # export PATH="$DEVROOT/usr/bin/:$PATH"
   # SYSROOT=$XCODE_DEV/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
   CFLAGS="-target $ARCH-apple-darwin"
   OPTIONS="$OPTIONS --host $ARCH-apple-darwin"
else
   OPTIONS="$OPTIONS"
fi

# Let's begin.
originalDir=`pwd`
cd $srcDir

# Start from scratch
make clean || true
rm -f configure
./bootstrap

# Run the configure script
CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" ./configure $OPTIONS

# Build
eval $BUILD_CMD
sudo make install

# Finally, return to the original directory
cd $originalDir

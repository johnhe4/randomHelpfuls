#!/bin/bash

# This is a helper script to configure, build, and install openssl.
########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/openssl

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

# Pulled from the Configure script
OPTIONS="--prefix=$INSTALL_PREFIX no-tests no-deprecated"

# Let's begin. First, enter the new directory
originalDir=`pwd`
cd $srcDir

BUILD_CMD="make -j"
if [ "$BUILD_FOR" = "iphoneos" ] || [ "$BUILD_FOR" = "iphonesimulator" ] || [ "$BUILD_FOR" = "macoscatalyst" ] || [ "$BUILD_FOR" = "xros" ] || [ "$BUILD_FOR" = "xrsimulator" ]; then
   XCODE_DEV="$(xcode-select -p)"
   if [ "$BUILD_FOR" = "iphoneos" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
      CFLAGS="-target $ARCH-apple-ios$MIN_IOS -isysroot $SYSROOT"
      OPTIONS="$OPTIONS ios64-cross"
   elif [ "$BUILD_FOR" = "iphonesimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
      CFLAGS="-target $ARCH-apple-darwin -isysroot $SYSROOT"
      OPTIONS="$OPTIONS iossimulator-xcrun"
   elif [ "$BUILD_FOR" = "xros" ]; then
      # TODO: This is different since xros isn't yet supported, so we modify the iOS version.
      # See https://github.com/openssl/openssl/blob/master/Configurations/15-ios.conf for more details 
      export CROSS_COMPILE="${XCODE_DEV}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
      export CROSS_TOP="${XCODE_DEV}/Platforms/XROS.platform/Developer"
      export CROSS_SDK=XROS.sdk
      CFLAGS="-target $ARCH-apple-xros"
      OPTIONS="$OPTIONS ios64-cross"
   elif [ "$BUILD_FOR" = "xrsimulator" ]; then
      # TODO: This is different since xros isn't yet supported, so we modify the iOS version.
      # See https://github.com/openssl/openssl/blob/master/Configurations/15-ios.conf for more details
      export CROSS_COMPILE="${XCODE_DEV}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
      export CROSS_TOP="${XCODE_DEV}/Platforms/XRSimulator.platform/Developer"
      export CROSS_SDK=XRSimulator.sdk
      CFLAGS="-target $ARCH-apple-darwin"
      OPTIONS="$OPTIONS iphoneos-cross"
   fi
   CFLAGS="$CFLAGS -arch $ARCH -Os"
   LDFLAGS="-arch $ARCH"
   OPTIONS="$OPTIONS no-async no-shared enable-ec_nistp_64_gcc_128"
elif [ "$BUILD_FOR" = "macos" ]; then
   OPTIONS="$OPTIONS no-async no-shared enable-ec_nistp_64_gcc_128 darwin64-$ARCH-cc"
else
   OPTIONS="$OPTIONS"
fi

# Run the configure script
CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" ./Configure $OPTIONS

# Build
make clean
$BUILD_CMD
sudo make install_sw

# Finally, return to the original directory
cd $originalDir

#!/bin/bash

# This is a helper script to configure and build openssl.
# If successful, you can install with `sudo make install_sw`. This make target will install openssl without
# all the bloated man docs.
########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/openssl

# Building for what?
# macos
# unix
# ios
# ios_simulator
# maccatalyst
# visionos
# visionos_simulator
#
# Note: you can do this once for each, then use 'lipo' to create a single fat library:
#  lipo -create libdevice.a libsimulator.a -output libcombined.a
BUILD_FOR=macos

# Target architecture
#  arm64
#  x86_64
ARCH=arm64

# Release or Debug?
BUILD_TYPE="-DCMAKE_BUILD_TYPE=Release"

# Minimum iOS version (if applicable)
MIN_IOS=15.0

# Installation prefix (if applicable)
INSTALL_PREFIX=/usr/local/macos_arm64

########## END USER EDIT SECTION #############
# Pulled from the Configure script
OPTIONS="no-tests no-deprecated"

if [ -n "$INSTALL_PREFIX" ]; then
   OPTIONS="$OPTIONS --prefix=$INSTALL_PREFIX"
fi

# Let's begin. First, enter the new directory
originalDir=`pwd`
cd $srcDir

if [ "$BUILD_FOR" = "iphoneos-cross" ]; then # TODO: UPDATE THIS, probably all wrong. look at the macos option
   DEVELOPER=`xcode-select -print-path`
   PLATFORM=iPhoneOS
   #TARGET=ios64-cross-arm64
   #ARCH="arm64"

   # Set build tools   
   export $PLATFORM
   export CROSS_COMPILE="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
   export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
   export CROSS_SDK="${PLATFORM}${SDK_VERSION}.sdk"
   OPTIONS="$TARGET no-async no-shared enable-ec_nistp_64_gcc_128"
elif [ "$BUILD_FOR" = "visionos" ]; then # TODO: UPDATE THIS, probably all wrong. look at the macos option
   DEVELOPER=`xcode-select -print-path`
   PLATFORM=XROS
   #TARGET=ios64-cross-arm64
   #ARCH="arm64"

   # Set build tools
   export $PLATFORM
   export CROSS_COMPILE="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
   export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
   export CROSS_SDK="${PLATFORM}${SDK_VERSION}.sdk"
   OPTIONS="$TARGET no-async no-shared enable-ec_nistp_64_gcc_128"
elif [ "$BUILD_FOR" = "macos" ]; then
   BUILD_CMD="make -j"
   OPTIONS="$OPTIONS no-async no-shared enable-ec_nistp_64_gcc_128 darwin64-$ARCH-cc"
else
   BUILD_CMD="make -j"
   OPTIONS="$OPTIONS"
fi

# Run the configure script
./Configure $OPTIONS

# Build
$BUILD_CMD

# Finally, return to the original directory
cd $originalDir

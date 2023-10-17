#!/bin/bash

# This is a helper script to configure and build libzfp.
# Get the code then run this script:
#   git clone git@github.com:alanxz/rabbitmq-c.git
# I have always stayed on the master branch because the tagged versions have outdated
# cmake configurations.

########## BEGIN USER EDIT SECTION #############

# Location of the source
# TODO: Depends on PR https://github.com/alanxz/rabbitmq-c/pull/794
srcDir=~/code/rabbitmq-c

# Feature selection, each one beginning with '-D' because it's CMAKE
FEATURES=" \
-DBUILD_SHARED_LIBS=OFF \
-DBUILD_EXAMPLES=OFF \
-DBUILD_TESTING=OFF \
"

# Build type
#  Debug
#  Release
#  MinSizeRel
BUILD_TYPE=Release

# Building for what?
# macos
# unix
# ios
# simulator
# maccatalyst
#
# Note: you can do this once for each, then use 'lipo' to create a single fat library:
#  lipo -create libdevice.a libsimulator.a -output libcombined.a
BUILD_FOR=macos

# Target architecture
#  arm64
#  x86_64
ARCH=arm64

# Minimum iOS version (if applicable)
MIN_IOS=15.0

# Installation prefix (if applicable)
INSTALL_PREFIX=/usr/local/macos_arm64

########## END USER EDIT SECTION #############

OPTIONS=" \
-DBUILD_SHARED_LIBS=OFF \
-DBUILD_TESTING=OFF \
-DENABLE_SSL_SUPPORT=ON \
-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
"

if [ -n "$INSTALL_PREFIX" ]; then
   OPTIONS="$OPTIONS -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX"
fi

BUILD_CMD="make -j16"
if [ "$BUILD_FOR" = "ios" ]; then
   SDK=iphoneos
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS"
   BUILD_CMD="xcodebuild build \
-project rabbitmq-c.xcodeproj \
-scheme rabbitmq-static \
-configuration $BUILD_TYPE \
-destination generic/platform=iOS \
BUILD_FOR_DISTRIBUTION=YES" 
elif [ "$BUILD_FOR" = "simulator" ]; then
   SDK=iphonesimulator
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS"
   BUILD_CMD="xcodebuild build \
-project rabbitmq-c.xcodeproj \
-scheme rabbitmq-static \
-configuration $BUILD_TYPE \
-sdk $SDK \
-arch $ARCH \
BUILD_FOR_DISTRIBUTION=YES"
elif [ "$BUILD_FOR" = "maccatalyst" ]; then
   SDK=maccatalyst
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"
   BUILD_CMD="xcodebuild build \
-project rabbitmq-c.xcodeproj \
-scheme rabbitmq-static \
-configuration $BUILD_TYPE \
-destination \"platform=macOS,variant=Mac Catalyst,arch=$ARCH\" \
BUILD_FOR_DISTRIBUTION=YES"
elif [ "$BUILD_FOR" = "macos" ]; then
   OPTIONS="$OPTIONS -DCMAKE_OSX_ARCHITECTURES=$ARCH"
#    OPENSSL_CRYPTO_LIBRARY           /usr/local/lib/libcrypto.dylib                                                                                                                                           
#  OPENSSL_INCLUDE_DIR              /usr/local/include                                                                                                                                                       
#  OPENSSL_SSL_LIBRARY              /usr/local/lib/libssl.dylib
else
   OPTIONS="$OPTIONS "
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
eval $BUILD_CMD

# Finally, return to the original directory
cd $originalDir
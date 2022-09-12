#!/bin/bash

# This is a helper script to configure and build libzfp.
# Get the code then run this script:
#   git clone git@github.com:alanxz/rabbitmq-c.git

########## BEGIN USER EDIT SECTION #############

# Location of the source
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
BUILD_TYPE=MinSizeRel

# Building for what?
# unix
# ios
# ios_simulator
# mac_catalyst
#
# Note: you can do this once for each, then use 'lipo' to create a single fat library:
#  lipo -create libdevice.a libsimulator.a -output libcombined.a
BUILD_FOR=ios_simulator

# Target architecture
#  arm64
#  x86_64
ARCH=arm64

# Minimum iOS version (if applicable)
MIN_IOS=13.0

# You may need to configure OpenSSL, but I didn't
OPEN_SSL=""

########## END USER EDIT SECTION #############

FEATURES="-DBUILD_SHARED_LIBS=OFF \
-DBUILD_SHARED_LIBS=OFF \
-DBUILD_TESTING=OFF \
-DENABLE_SSL_SUPPORT=OFF \
"

OPTIONS=""
BUILD_CMD="make -j16"
if [ "$BUILD_FOR" = "ios" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS"
   BUILD_CMD="xcodebuild build \
-project rabbitmq-c.xcodeproj \
-scheme rabbitmq-static \
-configuration $BUILD_TYPE \
-destination generic/platform=iOS \
BUILD_FOR_DISTRIBUTION=YES \
BITCODE_GENERATION_MODE=bitcode" 
elif [ "$BUILD_FOR" = "ios_simulator" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS"
   BUILD_CMD="xcodebuild build \
-project rabbitmq-c.xcodeproj \
-scheme rabbitmq-static \
-configuration $BUILD_TYPE \
-sdk iphonesimulator \
-arch $ARCH BUILD_FOR_DISTRIBUTION=YES \
BITCODE_GENERATION_MODE=bitcode"
elif [ "$BUILD_FOR" = "mac_catalyst" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"
   BUILD_CMD="xcodebuild build \
-project rabbitmq-c.xcodeproj \
-scheme rabbitmq-static \
-configuration $BUILD_TYPE \
-destination \"platform=macOS,variant=Mac Catalyst,arch=$ARCH\" \
BUILD_FOR_DISTRIBUTION=YES \
BITCODE_GENERATION_MODE=bitcode"
fi

# Let's begin.
originalDir=`pwd`
cd $srcDir
mkdir -p build
cd build

# Run the configure script
cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE $OPTIONS $FEATURES

# Build
eval $BUILD_CMD

# Finally, return to the original directory
cd $originalDir
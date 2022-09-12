#!/bin/bash

# This is a helper script to configure and build libzqm for mac.
#   git clone https://github.com/zeromq/libzmq.git

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/libzmq

# Build type
#  Debug
#  Release
#  MinSizeRel
BUILD_TYPE=MinSizeRel

# I installed the dependcies manually, letting grpc build only itself
# Feature selection, each one beginning with '-D' because it's CMAKE
FEATURES=" \
-DENABLE_DRAFTS=ON \
"

# Building for what?
#  ios
#  ios_simulator
#  mac_catalyst
BUILD_FOR=ios

# Target architecture
#  arm64
#  x86_64
ARCH=arm64

# Minimum iOS version (if applicable)
MIN_IOS=13.0

# You may need to configure OpenSSL, but I didn't
OPEN_SSL=""

########## END USER EDIT SECTION #############

FEATURES="$FEATURES \
-DZMQ_BUILD_FRAMEWORK=ON \
-DBUILD_SHARED=OFF \
-DBUILD_TESTS=OFF \
-DZMQ_BUILD_TESTS=OFF \
-DWITH_DOCS=OFF \
-DWITH_LIBSODIUM=OFF \
-DWITH_PERF_TOOL=OFF \
"

OPTIONS=""
BUILD_CMD="make -j16"
if [ "$BUILD_FOR" = "ios" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS"
   BUILD_CMD="xcodebuild build \
-project ZeroMQ.xcodeproj \
-scheme libzmq-static \
-configuration $BUILD_TYPE \
-destination generic/platform=iOS \
BUILD_FOR_DISTRIBUTION=YES \
BITCODE_GENERATION_MODE=bitcode" 
elif [ "$BUILD_FOR" = "ios_simulator" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS"
   BUILD_CMD="xcodebuild build \
-project ZeroMQ.xcodeproj \
-scheme libzmq-static \
-configuration $BUILD_TYPE \
-sdk iphonesimulator \
-arch $ARCH BUILD_FOR_DISTRIBUTION=YES \
BITCODE_GENERATION_MODE=bitcode"
elif [ "$BUILD_FOR" = "mac_catalyst" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"
   BUILD_CMD="xcodebuild build \
-project ZeroMQ.xcodeproj \
-scheme libzmq-static \
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
pwd

# Run the configure script
cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE $OPTIONS $OPEN_SSL $FEATURES

# Build
eval $BUILD_CMD

# Finally, return to the original directory
cd $originalDir

# iOS note: you can do this once for simulator and device, then use 'lipo' to create a fat library:
#  lipo -create libdevice.a libsimulator.a -output libcombined.a
# This is no longer recommended though, should use xcframework instead
#!/bin/bash

# This is a helper script to configure and build nlohmann json.
#   git clone https://github.com/google/flatbuffers.git

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/flatbuffers

# Build type
#  Debug
#  Release
#  MinSizeRel
BUILD_TYPE=Release

# Building for what?
# macos
# ios
# ios_simulator
# maccatalyst
# android
# visionos
# visionos_simulator
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
OPTIONS="$OPTIONS \
-DFLATBUFFERS_BUILD_TESTS=OFF \
-DFLATBUFFERS_ENABLE_PCH=ON \
"

if [ -n "$INSTALL_PREFIX" ]; then
   OPTIONS="$OPTIONS -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX"
fi

BUILD_CMD="make -j16"
if [ "$BUILD_FOR" = "ios" ]; then
   SDK=iphoneos
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS"
   BUILD_CMD="xcodebuild build \
-project ZeroMQ.xcodeproj \
-scheme libzmq-static \
-configuration $BUILD_TYPE \
-destination generic/platform=iOS \
BUILD_FOR_DISTRIBUTION=YES" 
elif [ "$BUILD_FOR" = "ios_simulator" ]; then
   SDK=iphonesimulator
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS"
   BUILD_CMD="xcodebuild build \
-project ZeroMQ.xcodeproj \
-scheme libzmq-static \
-configuration $BUILD_TYPE \
-sdk iphonesimulator \
-arch $ARCH \
BUILD_FOR_DISTRIBUTION=YES"
elif [ "$BUILD_FOR" = "maccatalyst" ]; then
   SDK=maccatalyst
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"
   BUILD_CMD="xcodebuild build \
-project ZeroMQ.xcodeproj \
-scheme libzmq-static \
-configuration $BUILD_TYPE \
-destination \"platform=macOS,variant=Mac Catalyst,arch=$ARCH\" \
BUILD_FOR_DISTRIBUTION=YES"
elif [ "$BUILD_FOR" = "visionos" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=visionOS"
   BUILD_CMD="xcodebuild build \
-project ZeroMQ.xcodeproj \
-scheme libzmq-static \
-configuration $BUILD_TYPE \
-destination generic/platform=xros \
BUILD_FOR_DISTRIBUTION=YES" 
elif [ "$BUILD_FOR" = "visionos_simulator" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=visionOS"
   BUILD_CMD="xcodebuild build \
-project ZeroMQ.xcodeproj \
-scheme libzmq-static \
-configuration $BUILD_TYPE \
-sdk xrsimulator \
-arch $ARCH \
BUILD_FOR_DISTRIBUTION=YES"
elif [ "$BUILD_FOR" = "android" ]; then
   OPTIONS="\
-DCMAKE_SYSTEM_NAME=Android \
-DCMAKE_SYSTEM_VERSION=32 \
-DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
-DCMAKE_PREFIX_PATH=/usr/local"
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
eval $BUILD_CMD

# Finally, return to the original directory
cd $originalDir

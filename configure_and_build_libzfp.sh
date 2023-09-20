#!/bin/bash

# This is a helper script to configure and build libzfp.
# Get the code then run this script:
#   git clone https://github.com/LLNL/zfp.git

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/libzfp

# I installed the dependcies manually, letting grpc build only itself
# Feature selection, each one beginning with '-D' because it's CMAKE
FEATURES=" \
"

# Build type
#  Debug
#  Release
#  MinSizeRel
BUILD_TYPE=MinSizeRel

# Building for what?
# ios
# ios_simulator
# mac_catalyst
# visionos
#
# Note: you can do this once for each, then use 'lipo' to create a single fat library:
#  lipo -create libdevice.a libsimulator.a -output libcombined.a
BUILD_FOR=visionos

# Target architecture
#  arm64
#  x86_64
ARCH=arm64

########## END USER EDIT SECTION #############

FEATURES="-DBUILD_SHARED_LIBS=OFF \
-DBUILD_TESTING=OFF \
-DBUILD_UTILITIES=OFF \
"

OPTIONS=""
BUILD_CMD="make -j16"
if [ "$BUILD_FOR" = "ios" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"
   BUILD_CMD="xcodebuild build -project ZFP.xcodeproj -scheme zfp -configuration $BUILD_TYPE -destination generic/platform=iOS BUILD_FOR_DISTRIBUTION=YES"
elif [ "$BUILD_FOR" = "ios_simulator" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"
   BUILD_CMD="xcodebuild build -project ZFP.xcodeproj -scheme zfp -configuration $BUILD_TYPE -sdk iphonesimulator -arch $ARCH BUILD_FOR_DISTRIBUTION=YES"
elif [ "$BUILD_FOR" = "mac_catalyst" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"
   BUILD_CMD="xcodebuild build -project ZFP.xcodeproj -scheme zfp -configuration $BUILD_TYPE -destination \"platform=macOS,variant=Mac Catalyst,arch=$ARCH\" BUILD_FOR_DISTRIBUTION=YES"
elif [ "$BUILD_FOR" = "visionos" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"
   #BUILD_CMD="xcodebuild build -project ZFP.xcodeproj -scheme zfp -configuration $BUILD_TYPE -destination \"platform=visionOS\" BUILD_FOR_DISTRIBUTION=YES"
   BUILD_CMD="xcodebuild build -project ZFP.xcodeproj -scheme zfp -configuration $BUILD_TYPE -destination generic/platform=visionOS BUILD_FOR_DISTRIBUTION=YES"
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

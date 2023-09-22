#!/bin/bash

# This is a helper script to configure and build libyaml.
#   git clone https://github.com/yaml/libyaml.git

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/libyaml

# Destination directory
destDir=~/code/libpropsync/iosLibs

# Build type
#  Debug
#  Release
#  MinSizeRel
BUILD_TYPE=MinSizeRel

# Building for what?
# macos
# ios
# ios_simulator
# maccatalyst
# android
# visionos
# visionos_simulator
BUILD_FOR=maccatalyst

# Target architecture
#  arm64
#  x86_64
ARCH=x86_64

# Minimum iOS version (if applicable)
MIN_IOS=13.0

########## END USER EDIT SECTION #############

FEATURES="$FEATURES \
-DBUILD_TESTING=OFF \
"

OPTIONS=""
BUILD_CMD="make -j16"
if [ "$BUILD_FOR" = "ios" ]; then
   SDK=iphoneos
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS"
   BUILD_CMD="xcodebuild build \
-project yaml.xcodeproj \
-scheme yaml \
-configuration $BUILD_TYPE \
-destination generic/platform=iOS \
BUILD_FOR_DISTRIBUTION=YES" 
elif [ "$BUILD_FOR" = "ios_simulator" ]; then
   SDK=iphonesimulator
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS"
   BUILD_CMD="xcodebuild build \
-project yaml.xcodeproj \
-scheme yaml \
-configuration $BUILD_TYPE \
-sdk iphonesimulator \
-arch $ARCH \
BUILD_FOR_DISTRIBUTION=YES"
elif [ "$BUILD_FOR" = "maccatalyst" ]; then
   SDK=maccatalyst
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"
   BUILD_CMD="xcodebuild build \
-project yaml.xcodeproj \
-scheme yaml \
-configuration $BUILD_TYPE \
-destination \"platform=macOS,variant=Mac Catalyst,arch=$ARCH\" \
BUILD_FOR_DISTRIBUTION=YES"
elif [ "$BUILD_FOR" = "visionos" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=visionOS"
   BUILD_CMD="xcodebuild build \
-project LibreSSL.xcodeproj \
-scheme ssl \
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
-DCMAKE_PREFIX_PATH=/usr/local \
"
fi

# Let's begin.
originalDir=`pwd`
cd $srcDir
mkdir -p build
cd build
pwd

# Run the configure script
cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE $OPTIONS $FEATURES

# Build
eval $BUILD_CMD

# Copy
# echo "Copying libyaml_${BUILD_FOR}_$ARCH.a to $destDir"
# cp lib/$BUILD_TYPE/libyaml.a $destDir/libyaml_${BUILD_FOR}_$ARCH.a

# Finally, return to the original directory
cd $originalDir

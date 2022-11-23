#!/bin/bash

# This is a helper script to configure and build libzfp.
# Get the code then run this script:
#   git clone git@github.com:alanxz/rabbitmq-c.git
# I have always stayed on the master branch because the tagged versions have outdated
# cmake configurations.

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/rabbitmq-c

# Destination directory
destDir=~/code/libpropsync/iosLibs

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
# unix
# ios
# simulator
# maccatalyst
#
# Note: you can do this once for each, then use 'lipo' to create a single fat library:
#  lipo -create libdevice.a libsimulator.a -output libcombined.a
BUILD_FOR=unix

# Target architecture
#  arm64
#  x86_64
ARCH=x86_64

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
   SDK=iphoneos
   export CFLAGS="$CFLAGS -fembed-bitcode"
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS"
   BUILD_CMD="xcodebuild build \
-project rabbitmq-c.xcodeproj \
-scheme rabbitmq-static \
-configuration $BUILD_TYPE \
-destination generic/platform=iOS \
BUILD_FOR_DISTRIBUTION=YES \
BITCODE_GENERATION_MODE=bitcode" 
elif [ "$BUILD_FOR" = "simulator" ]; then
   SDK=iphonesimulator
   export CFLAGS="$CFLAGS -fembed-bitcode"
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS"
   BUILD_CMD="xcodebuild build \
-project rabbitmq-c.xcodeproj \
-scheme rabbitmq-static \
-configuration $BUILD_TYPE \
-sdk $SDK \
-arch $ARCH \
BUILD_FOR_DISTRIBUTION=YES \
BITCODE_GENERATION_MODE=bitcode"
elif [ "$BUILD_FOR" = "maccatalyst" ]; then
   SDK=maccatalyst
   export CFLAGS="$CFLAGS -fembed-bitcode"
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"
   BUILD_CMD="xcodebuild build \
-project rabbitmq-c.xcodeproj \
-scheme rabbitmq-static \
-configuration $BUILD_TYPE \
-destination \"platform=macOS,variant=Mac Catalyst,arch=$ARCH\" \
BUILD_FOR_DISTRIBUTION=YES \
BITCODE_GENERATION_MODE=bitcode"
else
   OPTIONS="-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
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

# Copy
echo "Copying librabbitmq_${BUILD_FOR}_$ARCH.a to $destDir"
cp librabbitmq/$BUILD_TYPE-$SDK/librabbitmq.a $destDir/librabbitmq_${BUILD_FOR}_$ARCH.a

# Finally, return to the original directory
cd $originalDir
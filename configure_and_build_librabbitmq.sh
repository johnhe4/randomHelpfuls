#!/bin/bash

# This is a helper script to configure and build librabbitmq-c.
# Get the code then run this script:
#   git clone git@github.com:alanxz/rabbitmq-c.git

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/rabbitmq-c

# Build type
#  Debug
#  Release
#  MinSizeRel
BUILD_TYPE=MinSizeRel

# Minimum iOS version (if applicable)
MIN_IOS=15.0

# Minimum Android SDK version (if applicable)
ANDROID_SDK_VERSION=32

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
   echo "   android"
   echo "   linux"
   echo "   win32"
   echo ""
   echo " arch (required):"
   echo "   x86_64"
   echo "   arm64"
   echo ""
   echo " prefix (default: /usr/local/{host}_{arch})"
   exit -1
fi
BUILD_FOR=$1
ARCH=$2
INSTALL_PREFIX=$3
if [ -z "$INSTALL_PREFIX" ]; then
   INSTALL_PREFIX="/usr/local/${BUILD_FOR}_$ARCH"
fi

OPTIONS=" \
-DBUILD_SHARED_LIBS=OFF \
-DBUILD_TESTING=OFF \
-DENABLE_SSL_SUPPORT=ON \
-DENABLE_SSL_ENGINE_API=OFF \
-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
"

# These options are critical for iOS, visionOS, and Android. For reasons unknown to me,
# cmake completely ignores any prefix path given unless these are explicitly specified.
#  https://stackoverflow.com/questions/65494246/cmakes-find-package-ignores-the-paths-option-when-building-for-ios
OPTIONS="$OPTIONS \
-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH \
-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH \
-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH \
"

if [ -n "$INSTALL_PREFIX" ]; then
   OPTIONS="$OPTIONS -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX"
fi

BUILD_CMD="make -j16"
INSTALL_CMD="sudo make install"
if [ "$BUILD_FOR" = "iphoneos" ] || [ "$BUILD_FOR" = "iphonesimulator" ] || [ "$BUILD_FOR" = "macoscatalyst" ] || [ "$BUILD_FOR" = "xros" ] || [ "$BUILD_FOR" = "xrsimulator" ]; then
   XCODE_DEV="$(xcode-select -p)"
   if [ "$BUILD_FOR" = "iphoneos" ]; then
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS -DCMAKE_OSX_ARCHITECTURES=$ARCH"
   elif [ "$BUILD_FOR" = "iphonesimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS -DCMAKE_OSX_ARCHITECTURES=$ARCH -DCMAKE_OSX_SYSROOT=$SYSROOT"
   elif [ "$BUILD_FOR" = "macoscatalyst" ]; then
      echo NOT IMPLEMENTED
      exit 0
#       SDK=maccatalyst
#       OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=iOS"
#       BUILD_CMD="xcodebuild build \
# -project rabbitmq-c.xcodeproj \
# -scheme rabbitmq-static \
# -configuration $BUILD_TYPE \
# -destination \"platform=macOS,variant=Mac Catalyst,arch=$ARCH\" \
# BUILD_FOR_DISTRIBUTION=YES"
   elif [ "$BUILD_FOR" = "xros" ]; then
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=visionOS -DCMAKE_OSX_ARCHITECTURES=$ARCH"
   elif [ "$BUILD_FOR" = "xrsimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/XRSimulator.platform/Developer/SDKs/XRSimulator.sdk
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=visionOS -DCMAKE_OSX_ARCHITECTURES=$ARCH -DCMAKE_OSX_SYSROOT=$SYSROOT"
   fi
   echo "Building for $BUILD_FOR on $ARCH"
elif [ "$BUILD_FOR" = "android" ]; then
   if [ "$ARCH" = "arm64" ]; then
      OPTIONS="$OPTIONS -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a"
   else
      OPTIONS="$OPTIONS -DCMAKE_ANDROID_ARCH_ABI=x86_64"
   fi
   OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=Android -DCMAKE_SYSTEM_VERSION=$ANDROID_SDK_VERSION"
elif [ "$BUILD_FOR" = "macos" ]; then
   OPTIONS="$OPTIONS -DCMAKE_OSX_ARCHITECTURES=$ARCH"
elif [ "$BUILD_FOR" = "win32" ]; then
   #OPTIONS="$OPTIONS"
   BUILD_CMD="cmake --build ."
   INSTALL_CMD="cmake --build . --target install"
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
$BUILD_CMD
$INSTALL_CMD

# Finally, return to the original directory
cd $originalDir
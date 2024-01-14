#!/bin/bash

# Configure and build libxml2
#  git clone https://github.com/GNOME/libxml2

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/libxml2

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
   echo "   webasm"
   echo ""
   echo " arch (required):"
   echo "   x86_64"
   echo "   arm64"
   echo "   any (only valid for webasm)"
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

OPTIONS="-DBUILD_SHARED_LIBS=OFF \
-DLIBXML2_WITH_C14N=OFF \
-DLIBXML2_WITH_CATALOG=OFF \
-DLIBXML2_WITH_DEBUG=OFF \
-DLIBXML2_WITH_HTML=OFF \
-DLIBXML2_WITH_HTTP=OFF \
-DLIBXML2_WITH_ICONV=OFF \
-DLIBXML2_WITH_ISO8859X=OFF \
-DLIBXML2_WITH_LZMA=OFF \
-DLIBXML2_WITH_MODULES=OFF \
-DLIBXML2_WITH_OUTPUT=OFF \
-DLIBXML2_WITH_PATTERN=OFF \
-DLIBXML2_WITH_PROGRAMS=OFF \
-DLIBXML2_WITH_PYTHON=OFF \
-DLIBXML2_WITH_REGEXPS=OFF \
-DLIBXML2_WITH_SAX1=ON \
-DLIBXML2_WITH_SCHEMAS=OFF \
-DLIBXML2_WITH_SCHEMATRON=OFF \
-DLIBXML2_WITH_TESTS=OFF \
-DLIBXML2_WITH_THREADS=OFF \
-DLIBXML2_WITH_VALID=OFF \
-DLIBXML2_WITH_TREE=OFF \
-DLIBXML2_WITH_WRITER=OFF \
-DLIBXML2_WITH_XINCLUDE=OFF \
-DLIBXML2_WITH_XPATH=OFF \
-DLIBXML2_WITH_XPTR=OFF \
-DLIBXML2_WITH_ZLIB=OFF \
-DLIBXML2_WITH_PUSH=ON \
-DLIBXML2_WITH_READER=OFF \
-DCMAKE_C_STANDARD=11 \
-DCMAKE_CXX_STANDARD=17 \
"

if [ -n "$INSTALL_PREFIX" ]; then
   OPTIONS="$OPTIONS -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX"
fi

BUILD_CMD="make -j16"
CONFIGURE_CMD="cmake .."
if [ "$BUILD_FOR" = "iphoneos" ] || [ "$BUILD_FOR" = "iphonesimulator" ] || [ "$BUILD_FOR" = "macoscatalyst" ] || [ "$BUILD_FOR" = "xros" ] || [ "$BUILD_FOR" = "xrsimulator" ]; then
   XCODE_DEV="$(xcode-select -p)"
   if [ "$BUILD_FOR" = "iphoneos" ]; then
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS -DCMAKE_OSX_ARCHITECTURES=$ARCH"
   elif [ "$BUILD_FOR" = "iphonesimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS -DCMAKE_OSX_ARCHITECTURES=$ARCH -DCMAKE_OSX_SYSROOT=$SYSROOT"
   elif [ "$BUILD_FOR" = "macoscatalyst" ]; then
      echo NOT IMPLEMENTED
   elif [ "$BUILD_FOR" = "xros" ]; then
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=visionOS -DCMAKE_OSX_ARCHITECTURES=$ARCH"
   elif [ "$BUILD_FOR" = "xrsimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/XRSimulator.platform/Developer/SDKs/XRSimulator.sdk
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=visionOS -DCMAKE_OSX_ARCHITECTURES=$ARCH -DCMAKE_OSX_SYSROOT=$SYSROOT"
   fi
elif [ "$BUILD_FOR" = "android" ]; then
   if [ "$ARCH" = "arm64" ]; then
      OPTIONS="$OPTIONS -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a"
   else
      OPTIONS="$OPTIONS -DCMAKE_ANDROID_ARCH_ABI=x86_64"
   fi
   OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=Android -DCMAKE_SYSTEM_VERSION=$ANDROID_SDK_VERSION -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX"
elif [ "$BUILD_FOR" = "webasm" ]; then
   CONFIGURE_CMD="emcmake cmake .."
   BUILD_CMD="emmake make -j16"
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
$CONFIGURE_CMD -DCMAKE_BUILD_TYPE=$BUILD_TYPE $OPTIONS

# Build
$BUILD_CMD
sudo make install

# Finally, return to the original directory
cd $originalDir

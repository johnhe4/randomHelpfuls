#!/bin/bash

# Configure and build libxml2 on mac
#  git clone https://github.com/GNOME/libxml2

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/libxml2

# Build type
#  Debug
#  Release
#  MinSizeRel
BUILD_TYPE=MinSizeRel

# Building for what?
# ios
# ios_simulator
# mac_catalyst
BUILD_FOR=ios

# Target architecture
#  arm64
#  x86_64
ARCH=arm64

########## END USER EDIT SECTION #############

FEATURES="-DBUILD_SHARED_LIBS=OFF \
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

OPTIONS=""
BUILD_CMD="make -j16"
if [ "$BUILD_FOR" = "ios" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"
   BUILD_CMD="xcodebuild build -project libxml2.xcodeproj -scheme LibXml2 -configuration $BUILD_TYPE -destination generic/platform=iOS BUILD_FOR_DISTRIBUTION=YES BITCODE_GENERATION_MODE=bitcode"
elif [ "$BUILD_FOR" = "ios_simulator" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"
   BUILD_CMD="xcodebuild build -project libxml2.xcodeproj -scheme LibXml2 -configuration $BUILD_TYPE -sdk iphonesimulator -arch $ARCH BUILD_FOR_DISTRIBUTION=YES BITCODE_GENERATION_MODE=bitcode"
elif [ "$BUILD_FOR" = "mac_catalyst" ]; then
   OPTIONS="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"
   BUILD_CMD="xcodebuild build -project libxml2.xcodeproj -scheme LibXml2 -configuration $BUILD_TYPE -destination \"platform=macOS,variant=Mac Catalyst,arch=$ARCH\" BUILD_FOR_DISTRIBUTION=YES BITCODE_GENERATION_MODE=bitcode"
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
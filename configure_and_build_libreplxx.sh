#!/bin/bash

# This is a helper script to configure and build libreplxx
# Get the code then run this script:
#   git clone git@github.com:AmokHuginnsson/replxx.git

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/replxx

# Destination directory
destDir=~/code/libpropsync/iosLibs

# Feature selection, each one beginning with '-D' because it's CMAKE
FEATURES=" \
-DBUILD_SHARED_LIBS=OFF \
-DREPLXX_BUILD_EXAMPLES=OFF \
"

# Build type
#  Debug
#  Release
#  MinSizeRel
BUILD_TYPE=Release

# Building for what?
# unix
#
# Note: you can do this once for each, then use 'lipo' to create a single fat library:
#  lipo -create libdevice.a libsimulator.a -output libcombined.a
BUILD_FOR=unix

# Target architecture
#  arm64
#  x86_64
ARCH=x86_64

########## END USER EDIT SECTION #############

OPTIONS=""
BUILD_CMD="make -j16"
OPTIONS="-DCMAKE_POSITION_INDEPENDENT_CODE=ON"

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

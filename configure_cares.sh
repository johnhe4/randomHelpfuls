#!/bin/bash

# This is a helper script to configure c-ares. THIS DOES NOT BUILD ANYTHING!
# It will enter the source directory and run the configuration script. It will
# then return to this directory and you will have to manually enter the ffmpeg
# directory type 'make'.
#

########## BEGIN USER EDIT SECTION #############

srcDir=~/code/c-ares

# Feature selection, each one beginning with '-D' because it's CMAKE
FEATURES=" \
   -DCARES_BUILD_TOOLS=OFF \
   -DCARES_SHARED=OFF \
   -DCARES_STATIC=ON \
   -DCARES_STATIC_PIC=ON \
"

# Release or Debug?
BUILD_TYPE="-DCMAKE_BUILD_TYPE=Release"

# Normal or iOS build? If iOS you'll need to open the Xcode project and build the 'install' target.
# Make sure to set the targ to "Any iOS Device".
# Then, from the command line, you can run:
#   sudo xcodebuild -target install
#PLATFORM=""
PLATFORM="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"

########## END USER EDIT SECTION #############

# Let's begin. First, enter the new directory
originalDir=`pwd`
cd $srcDir

# Out-of-tree build
mkdir -p build
cd build 

# Run the configure script
cmake .. $PLATFORM $BUILD_TYPE $FEATURES 

# Finally, return to the original directory
cd $originalDir

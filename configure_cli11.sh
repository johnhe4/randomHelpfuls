#!/bin/bash

# This is a helper script to configure and build CLI11.
# Get the code then run this script:
#   git clone https://github.com/CLIUtils/CLI11.git

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/CLI11

# I installed the dependcies manually, letting grpc build only itself
# Feature selection, each one beginning with '-D' because it's CMAKE
FEATURES=" \
-DBUILD_TESTING=OFF \
-DCLI11_BUILD_EXAMPLES=OFF \
"

# Release or Debug?
BUILD_TYPE="-DCMAKE_BUILD_TYPE=Release"

########## END USER EDIT SECTION #############

BUILD_FOR=""

# Let's begin. First, enter the new directory
originalDir=`pwd`
cd $srcDir

# Out-of-tree build
mkdir -p build
cd build 

# Run the configure script
cmake .. $BUILD_FOR $BUILD_TYPE $FEATURES

# Finally, return to the original directory
cd $originalDir

#!/bin/bash

# This is a helper script to configure PROJ. THIS DOES NOT BUILD ANYTHING!
# It will enter the source directory and run the configuration script. It will
# then return to this directory and you will have to manually build.
#
# You can read more about configurinng PROJ here:
#   https://github.com/OSGeo/PROJ/tree/master

########## BEGIN USER EDIT SECTION #############

srcDir=~/code/PROJ

# Featur selection, each one beginning with '-D' because it's CMAKE
FEATURES=" \
-DENABLE_CURL=OFF \
-DBUILD_PROJSYNC=OFF \
-DBUILD_TESTING=OFF \
"

# Release or Debug?
BUILD_TYPE="-DCMAKE_BUILD_TYPE=Release"

########## END USER EDIT SECTION #############

# Let's begin. First, enter the new directory
originalDir=`pwd`
cd $srcDir

# Out-of-tree build
mkdir -p build
cd build 

# Run the configure script
cmake .. $FEATURES $BUILD_TYPE

# Finally, return to the original directory
cd $originalDir

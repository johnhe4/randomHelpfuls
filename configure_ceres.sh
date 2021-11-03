#!/bin/bash

# This is a helper script to configure ceares. THIS DOES NOT BUILD ANYTHING!
# It will enter the source directory and run the configuration script. 

########## BEGIN USER EDIT SECTION #############

# IMPORTANT: if building for iOS you need to grab the branch here (unless it has been merged to main):
# https://ceres-solver-review.googlesource.com/c/ceres-solver/+/19180

srcDir=~/code/ceres-solver

# ASSUMING IOS HERE
# Feature selection, each one beginning with '-D' because it's CMAKE
FEATURES=" \
   -DCMAKE_TOOLCHAIN_FILE=../cmake/iOS.cmake \
   -DEigen3_DIR=/usr/local/share/eigen3/cmake/ \
   -DBUILD_TESTING=OFF \
   -DEXPORT_BUILD_DIR=ON \
   -DENABLE_BITCODE=ON \
"

# Release or Debug?
BUILD_TYPE="-DCMAKE_BUILD_TYPE=Release"

########## END USER EDIT SECTION #############

# Let's begin. First, enter the new directory
originalDir=`pwd`
cd $srcDir

# Ceres is certainly not cmake friendly as it has a file named BUILD
# Out-of-tree build
mkdir -p buildDir
cd buildDir 

# Run the configure script
cmake .. $PLATFORM $BUILD_TYPE $FEATURES 

# Finally, return to the original directory
cd $originalDir

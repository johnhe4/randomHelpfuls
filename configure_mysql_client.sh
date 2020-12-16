#!/bin/bash

# This is a helper script to configure mysql (client only) on mac.
# THIS DOES NOT BUILD ANYTHING!
# It will enter the source directory and run the configuration script. It will
# then return to this directory and you will have to manually enter the 
# directory type 'make'.
#
########## BEGIN USER EDIT SECTION #############

srcDir=~/code/mysql-server

# Build options, each one beginning with '-D' because it's CMAKE
BUILD_OPTIONS=" \
 -DWITH_UNIT_TESTS=OFF \
 -DINSTALL_BINDIR=/usr/local/bin \
 -DINSTALL_INCLUDEDIR=/usr/local/include \
 -DINSTALL_LIBDIR=/usr/local/lib \
 -DWITHOUT_SERVER=ON \
 -DDOWNLOAD_BOOST=1 \
 -DWITH_BOOST=./boost \
 -DOPENSSL_INCLUDE_DIR=/usr/local/include \
 -DOPENSSL_LIBRARIES=/usr/local/lib
"
 #-DWITH_SSL=/usr/local/ssl

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
cmake .. $BUILD_OPTIONS $BUILD_TYPE

# Finally, return to the original directory
cd $originalDir

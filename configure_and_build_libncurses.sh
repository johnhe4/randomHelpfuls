#!/bin/bash

# This is a helper script to configure and build libncurses.
# Get the code then run this script:
#   git clone https://github.com/mirror/ncurses

########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/ncurses

# I installed the dependcies manually, letting grpc build only itself
# Feature selection, each one beginning with '-D' because it's CMAKE
OPTIONS=" \
--without-ada \
--without-cxx \
--without-cxx-binding \
--disable-db-install \
--without-manpages \
--without-progs \
--without-tack \
--without-tests \
--with-normal \
--without-dlsym \
"

# Build type
#  Debug
#  Release
#  MinSizeRel
#BUILD_TYPE=MinSizeRel

# Target architecture
#  arm64
#  x86_64
#ARCH=x86_64

########## END USER EDIT SECTION #############

BUILD_CMD="make -j"

# Let's begin.
originalDir=`pwd`
cd $srcDir

# Start from scratch
make clean || true

# Run the configure script
./configure $OPTIONS

# Build
eval $BUILD_CMD

# Finally, return to the original directory
cd $originalDir

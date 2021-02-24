#!/bin/bash

# Instructions to configure and build openssl for iPhone. I tried
# to do this on my own (see code below `exit`) but failed.
# Thankfully some other folks figured this out
echo "Read the contents of the script"

# Step 1
#  git clone https://github.com/x2on/OpenSSL-for-iPhone.git

# Step 2
#  cd OpenSSL-for-iPhone
#  ./build-libssl.sh --targets="ios64-cross-arm64"

# Step 3
# Grab the libs and use them, or point to the root directory of this project (OpenSSL-for-iPhone).
# I don't know if the headers are the same for every platform, and I don't know how to "install" these to the system.
exit 0

srcDir=~/code/openssl

# Release or Debug?
#BUILD_TYPE="-DCMAKE_BUILD_TYPE=Release"

# Building for what?
# iphoneos-cross
# ios-cross
# ios-xcrun
# ios64-cross 
# ios64-xcrun
# iossimulator-xcrun
# iphoneos-cross
# darwin64-x86_64-cc
BUILD_FOR=ios64-cross

########## END USER EDIT SECTION #############

OPTIONS=""

# Let's begin. First, enter the new directory
originalDir=`pwd`
cd $srcDir

if [ "$BUILD_FOR" = "iphoneos-cross" ]; then
   DEVELOPER=`xcode-select -print-path`
   PLATFORM=iPhoneOS
   #TARGET=ios64-cross-arm64
   #ARCH="arm64"

   # Set build tools   
   export $PLATFORM
   export CROSS_COMPILE="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
   export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
   export CROSS_SDK="${PLATFORM}${SDK_VERSION}.sdk"
   OPTIONS="$TARGET no-deprecated no-async no-shared no-tests enable-ec_nistp_64_gcc_128"
fi

# Run the configure script
./Configure $BUILD_FOR $OPTIONS

# Finally, return to the original directory
cd $originalDir

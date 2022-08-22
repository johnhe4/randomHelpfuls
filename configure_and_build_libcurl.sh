#!/bin/bash

# An possible alternate to this home-made script is:
#   https://github.com/jasonacox/Build-OpenSSL-cURL
#
# This is a helper script to configure and build libcurl.
# Get the code then run this script:
#   git clone git@github.com:curl/curl.git
# 
# Tested with tag curl-7_84_0
#
# Requirements:
#  - install automake, autoconf, libtool. Use homebrew if you don't want to build and install manually
#  - after installing you may need to symlink libtoolize:
#      ln -s /usr/local/bin/glibtoolize /usr/local/bin/libtoolize
#  - You need to run `autoreconf -fi` from the curl directory before calling this script,
#    including when you change the platform or architecture
#
########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/curl

# Building for what?
# unix
# ios
# ios_simulator
# mac_catalyst
#
# Note: you can do this once for each, then use 'lipo' to create a single fat library:
#  lipo -create libdevice.a libsimulator.a -output libcombined.a
BUILD_FOR=ios_simulator

# Target architecture
#  arm64
#  x86_64
ARCH=arm64

########## END USER EDIT SECTION #############

BUILD_CMD="make -j"

if [ "$BUILD_FOR" = "ios" ] || [ "$BUILD_FOR" = "ios_simulator" ] || [ "$BUILD_FOR" = "mac_catalyst" ]; then
   XCODE_DEV="$(xcode-select -p)"
   export DEVROOT="$XCODE_DEV/Toolchains/XcodeDefault.xctoolchain"
   export PATH="$DEVROOT/usr/bin/:$PATH"
   if [ "$BUILD_FOR" = "ios" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
      OPTIONS="--host=$ARCH-apple-ios"
   elif [ "$BUILD_FOR" = "ios_simulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
      OPTIONS="--host=$ARCH-apple-ios"
   elif [ "$BUILD_FOR" = "mac_catalyst" ]; then
      SYSROOT=$XCODE_DEV/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
      CFLAGS="-target x86_64-apple-ios15.0-macabi"
      OPTIONS=""
      #OPTIONS="--host=$ARCH-apple-mac-catalyst" May need something like this? Not sure
   fi
   export CFLAGS="$CFLAGS -arch $ARCH -Os -isysroot $SYSROOT -fembed-bitcode"
   export LDFLAGS="-arch $ARCH -isysroot $SYSROOT"
   echo "Building for $BUILD_FOR on $ARCH (sysroot=$SYSROOT)"
   OPTIONS="$OPTIONS \
--with-secure-transport \
--enable-static \
--enable-ipv6 \
--without-zlib \
--without-brotli \
--disable-shared \
--disable-manual \
--disable-ftp \
--disable-file \
--disable-ldap \
--disable-ldaps \
--disable-rtsp \
--disable-proxy \
--disable-dict \
--disable-telnet \
--disable-tftp \
--disable-pop3 \
--disable-imap \
--disable-smtp \
--disable-gopher \
--disable-sspi \
--disable-smb \
--disable-unix-sockets \
"
else
   OPTIONS=""   
fi

# Let's begin.
originalDir=`pwd`
cd $srcDir

# Run the configure script
./configure $OPTIONS

# Build
$BUILD_CMD

# Finally, return to the original directory
cd $originalDir

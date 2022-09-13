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
# NOTES:
#  - install automake, autoconf, libtool. Use homebrew if you don't want to build and install manually
#  - after installing you may need to symlink libtoolize:
#      ln -s /usr/local/bin/glibtoolize /usr/local/bin/libtoolize
#  - This will call `autoreconf -fi` before configuring to avoid errors in the cases where the arch or build target changes.
#  - This is building libcurl as a static library and doesn't care about the actual curl application. 
#    If you see linker errors then ignore them because they probably apply to curl - static libraries are not linked.
#
########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/curl

# Destination directory
destDir=~/code/libpropsync/iosLibs

# Building for what?
# unix
# ios
# simulator
# maccatalyst
#
# Note: you can do this on/targetce for each, then use 'lipo' to create a single fat library:
#  lipo -create libdevice.a libsimulator.a -output libcombined.a
BUILD_FOR=simulator

# Target architecture
#  arm64
#  x86_64
ARCH=arm64

# Minimum iOS version (if applicable)
MIN_IOS=13.0

########## END USER EDIT SECTION #############

BUILD_CMD="make -j"

if [ "$BUILD_FOR" = "ios" ] || [ "$BUILD_FOR" = "simulator" ] || [ "$BUILD_FOR" = "maccatalyst" ]; then
   XCODE_DEV="$(xcode-select -p)"
   export DEVROOT="$XCODE_DEV/Toolchains/XcodeDefault.xctoolchain"
   export PATH="$DEVROOT/usr/bin/:$PATH"
   if [ "$BUILD_FOR" = "ios" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
      CFLAGS="-target $ARCH-apple-ios$MIN_IOS"
      OPTIONS="--host=$ARCH-apple-ios"
   elif [ "$BUILD_FOR" = "simulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
      #CFLAGS="-target $ARCH-apple-ios$MIN_IOS"
      OPTIONS="--host=$ARCH-apple-darwin"
   elif [ "$BUILD_FOR" = "maccatalyst" ]; then
      SYSROOT=$XCODE_DEV/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
      CFLAGS="-target $ARCH-apple-ios15.0-macabi"
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
--disable-debug \
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

# Start from scratch
autoreconf -fi
make clean || true

# Run the configure script
./configure $OPTIONS

# Build. Don't worry about errors, we don't care about curl, just libcurl
$BUILD_CMD || true

# Copy
echo "Copying libcurl_${BUILD_FOR}_$ARCH.a to $destDir"
cp lib/.libs/libcurl.a $destDir/libcurl_${BUILD_FOR}_$ARCH.a

# Finally, return to the original directory
cd $originalDir

#!/bin/bash

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

# Minimum iOS version (if applicable)
MIN_IOS=15.0

# Minimum Android SDK version (if applicable)
ANDROID_SDK_VERSION=32

########## END USER EDIT SECTION #############

if [ $# -lt 2 ]; then
   echo " <this_script>.sh host arch prefix"
   echo ""
   echo " host (required):"
   echo "   macos"
   echo "   macoscatalyst"
   echo "   iphoneos"
   echo "   iphonesimulator"
   echo "   xros"
   echo "   xrsimulator"
   echo "   android"
   echo "   linux"
   echo "   win32"
   echo ""
   echo " arch (required):"
   echo "   x86_64"
   echo "   arm64"
   echo ""
   echo " prefix (default: /usr/local/{host}_{arch})"
   exit -1
fi
BUILD_FOR=$1
ARCH=$2
INSTALL_PREFIX=$3
if [ -z "$INSTALL_PREFIX" ]; then
   INSTALL_PREFIX="/usr/local/${BUILD_FOR}_$ARCH"
fi

OPTIONS=" \
--enable-ipv6 \
--without-zlib \
--without-brotli \
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
--disable-ntlm \
--disable-docs \
--without-nghttp2 \
--enable-static=yes \
--enable-shared=no \
--disable-shared \
--disable-websockets \
--without-zstd \
--without-libpsl \
"

if [ -n "$INSTALL_PREFIX" ]; then
   OPTIONS="$OPTIONS --prefix=$INSTALL_PREFIX"
   export PKG_CONFIG_PATH="$INSTALL_PREFIX/lib/pkgconfig"
fi

PREBUILD_CMD="rm -f configure; autoreconf -fi"
BUILD_CMD="make -j"
INSTALL_CMD="sudo make install"
if [ "$BUILD_FOR" = "iphoneos" ] || [ "$BUILD_FOR" = "iphonesimulator" ] || [ "$BUILD_FOR" = "macoscatalyst" ] || [ "$BUILD_FOR" = "xros" ] || [ "$BUILD_FOR" = "xrsimulator" ]; then
   XCODE_DEV="$(xcode-select -p)"
   export DEVROOT="$XCODE_DEV/Toolchains/XcodeDefault.xctoolchain"
   export PATH="$DEVROOT/usr/bin/:$PATH"
   if [ "$BUILD_FOR" = "iphoneos" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
      CFLAGS="-target $ARCH-apple-ios$MIN_IOS"
      OPTIONS="$OPTIONS --host=$ARCH-apple-ios"
   elif [ "$BUILD_FOR" = "iphonesimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
      OPTIONS="$OPTIONS --host=$ARCH-apple-darwin"
   elif [ "$BUILD_FOR" = "macoscatalyst" ]; then
      SYSROOT=$XCODE_DEV/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
      CFLAGS="-target $ARCH-apple-ios15.0-macabi"
      OPTIONS="$OPTIONS"
   elif [ "$BUILD_FOR" = "xros" ]; then
      SYSROOT=$XCODE_DEV/Platforms/XROS.platform/Developer/SDKs/XROS.sdk
      CFLAGS="-target $ARCH-apple-xros"
      OPTIONS="$OPTIONS --host=$ARCH-apple-ios"
   elif [ "$BUILD_FOR" = "xrsimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/XRSimulator.platform/Developer/SDKs/XRSimulator.sdk
      OPTIONS="$OPTIONS --host=$ARCH-apple-darwin"
   fi
   CFLAGS="$CFLAGS -arch $ARCH -Os -isysroot $SYSROOT"
   LDFLAGS="-arch $ARCH -isysroot $SYSROOT"
   echo "Building for $BUILD_FOR on $ARCH (sysroot=$SYSROOT)"
   OPTIONS="$OPTIONS --disable-unix-sockets"
elif [ "$BUILD_FOR" = "android" ]; then
   # Following guidelines from https://developer.android.com/ndk/guides/other_build_systems
   # and https://curl.se/docs/install.html
   unameOut="$(uname -s)"
   case "${unameOut}" in
      Linux*)     HOST_TAG=linux-x86_64;;
      Darwin*)    HOST_TAG=darwin-x86_64;;
      *)          HOST_TAG="UNKNOWN host type: ${unameOut}"
   esac

   if [ "$ARCH" = "arm64" ]; then
         OPTIONS="$OPTIONS --host aarch64-linux-android"
         TOOLS_ARCH="arm64-v8a"
      else
         OPTIONS="$OPTIONS --host x86_64-linux-android"
         TOOLS_ARCH="x86_64"
      fi

   # Assuming ANDROID_NDK is properly installed and set
   export ANDROID_NDK_HOME=$ANDROID_NDK
   export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG
   export AR=$TOOLCHAIN/bin/llvm-ar
   export AS=$TOOLCHAIN/bin/llvm-as
   export CC=$TOOLCHAIN/bin/$TOOLS_ARCH-linux-android$ANDROID_SDK_VERSION-clang
   export CXX=$TOOLCHAIN/bin/$TOOLS_ARCH-linux-android$ANDROID_SDK_VERSION-clang++
   export LD=$TOOLCHAIN/bin/ld
   export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
   export STRIP=$TOOLCHAIN/bin/llvm-strip
   OPTIONS="$OPTIONS --with-ca-path=/system/etc/security/cacerts --with-openssl=$INSTALL_PREFIX --without-secure-transport"
elif [ "$BUILD_FOR" = "macos" ]; then
   CFLAGS="-target $ARCH-apple-darwin"
   OPTIONS="$OPTIONS --host $ARCH-apple-darwin --without-openssl --with-secure-transport"
elif [ "$BUILD_FOR" = "win32" ]; then
   #OPTIONS="$OPTIONS --without-openssl --with-schannel"
   OPTIONS="MACHINE=x64 ENABLE_SCHANNEL=yes"
   PREBUILD_CMD="./buildconf.bat; cd winbuild"
   BUILD_CMD="nmake /f Makefile.vc mode=static $OPTIONS"
   INSTALL_CMD="cmake --build . --target install"
else
   OPTIONS="$OPTIONS"
fi

# Let's begin.
originalDir=`pwd`
cd $srcDir

export CFLAGS="$CFLAGS"
export LDFLAGS="$LDFLAGS"

# Start from scratch
eval $PREBUILD_CMD

# Run the configure script
./configure $OPTIONS

# Build. Don't worry about errors, we don't care about curl, just libcurl
$BUILD_CMD || true

$INSTALL_CMD

# Finally, return to the original directory
cd $originalDir

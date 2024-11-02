#!/bin/bash

# This is a helper script to configure, build, and install openssl.
########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/openssl

# Build type
#  debug
#  release
BUILD_TYPE=release

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

# Pulled from the Configure script, search for @disablables.
# Also in https://github.com/openssl/openssl/blob/master/INSTALL.md
OPTIONS="--prefix=$INSTALL_PREFIX \
no-afalgeng \
no-aria \
no-asan \
no-asm \
no-autoalginit \
no-autoerrinit \
no-bf \
no-blake2 \
no-camellia \
no-capieng \
no-cast \
no-cmac \
no-cms \
no-comp \
no-crypto-mdebug \
no-crypto-mdebug-backtrace \
no-deprecated \
no-ec_nistp_64_gcc_128 \
no-engine \
no-dynamic-engine \
no-devcryptoeng \
no-dgram \
no-external-tests \
no-fuzz-libfuzzer \
no-fuzz-afl \
no-ct \
no-weak-ssl-ciphers \
no-zlib \
no-zlib-dynamic \
no-ubsan \
no-ui-console \
no-unit-test \
no-whirlpool \
no-ssl-trace \
no-tests \
no-threads \
no-des \
no-dso \
no-egd \
no-err \
no-filenames \
no-gost \
no-heartbeats \
no-idea \
no-makedepend \
no-md2 \
no-md4 \
no-mdc2 \
no-msan \
no-multiblock \
no-nextprotoneg \
no-pinshared \
no-ocb \
no-ocsp \
no-poly1305 \
no-posix-io \
no-psk \
no-rc2 \
no-rc4 \
no-rc5 \
no-rdrand \
no-rfc3779 \
no-rmd160 \
no-scrypt \
no-sctp \
no-seed \
no-shared \
no-siphash \
no-sm2 \
no-sm3 \
no-sm4 \
no-srp \
no-srtp \
no-sse2 \
no-ts \
"

# Let's begin. First, enter the new directory
originalDir=`pwd`
cd $srcDir

BUILD_CMD="make -j"
if [ "$BUILD_FOR" = "iphoneos" ] || [ "$BUILD_FOR" = "iphonesimulator" ] || [ "$BUILD_FOR" = "macoscatalyst" ] || [ "$BUILD_FOR" = "xros" ] || [ "$BUILD_FOR" = "xrsimulator" ]; then
   XCODE_DEV="$(xcode-select -p)"
   if [ "$BUILD_FOR" = "iphoneos" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
      CFLAGS="-target $ARCH-apple-ios$MIN_IOS -isysroot $SYSROOT"
      OPTIONS="$OPTIONS ios64-cross"
   elif [ "$BUILD_FOR" = "iphonesimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
      CFLAGS="-target $ARCH-apple-darwin -isysroot $SYSROOT"
      OPTIONS="$OPTIONS iossimulator-xcrun"
   elif [ "$BUILD_FOR" = "macoscatalyst" ]; then
      SYSROOT=$XCODE_DEV/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
      CFLAGS="-target $ARCH-apple-ios15.0-macabi -miphoneos-version-min=15.0 -isysroot $SYSROOT"
      OPTIONS="$OPTIONS ios64-cross"
   elif [ "$BUILD_FOR" = "xros" ]; then
      # TODO: This is different since xros isn't yet supported, so we modify the iOS version.
      # See https://github.com/openssl/openssl/blob/master/Configurations/15-ios.conf for more details 
      export CROSS_COMPILE="${XCODE_DEV}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
      export CROSS_TOP="${XCODE_DEV}/Platforms/XROS.platform/Developer"
      export CROSS_SDK=XROS.sdk
      CFLAGS="-target $ARCH-apple-xros"
      OPTIONS="$OPTIONS ios64-cross"
   elif [ "$BUILD_FOR" = "xrsimulator" ]; then
      # TODO: This is different since xros isn't yet supported, so we modify the iOS version.
      # See https://github.com/openssl/openssl/blob/master/Configurations/15-ios.conf for more details
      export CROSS_COMPILE="${XCODE_DEV}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
      export CROSS_TOP="${XCODE_DEV}/Platforms/XRSimulator.platform/Developer"
      export CROSS_SDK=XRSimulator.sdk
      CFLAGS="-target $ARCH-apple-darwin"
      OPTIONS="$OPTIONS iphoneos-cross"
   fi
   CFLAGS="$CFLAGS -arch $ARCH -Os"
   LDFLAGS="-arch $ARCH"
   OPTIONS="$OPTIONS no-async no-shared enable-ec_nistp_64_gcc_128"
elif [ "$BUILD_FOR" = "android" ]; then
   # Following guidelines from https://developer.android.com/ndk/guides/other_build_systems
   # and from NOTES.Android in openssl code repository
   unameOut="$(uname -s)"
   case "${unameOut}" in
      Linux*)     HOST_TAG=linux-x86_64;;
      Darwin*)    HOST_TAG=darwin-x86_64;;
      *)          HOST_TAG="UNKNOWN host type: ${unameOut}"
   esac

   # Assuming ANDROID_NDK is properly installed and set
   SYSROOT=$ANDROID_NDK/toolchains/llvm/prebuilt/$HOST_TAG

   export PATH=$SYSROOT/bin:$PATH
   export ANDROID_NDK_HOME=$ANDROID_NDK
   OPTIONS="$OPTIONS no-async no-shared enable-ec_nistp_64_gcc_128 -D__ANDROID_API__=$ANDROID_SDK_VERSION android-$ARCH "
elif [ "$BUILD_FOR" = "macos" ]; then
   OPTIONS="$OPTIONS no-async no-shared enable-ec_nistp_64_gcc_128 darwin64-$ARCH-cc"
elif [ "$BUILD_FOR" = "win32" ]; then
   OPTIONS="$OPTIONS"
else
   OPTIONS="$OPTIONS"
fi

# Run the configure script
CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" ./Configure $OPTIONS --$BUILD_TYPE

# Build
make clean
$BUILD_CMD
sudo make install_sw

# Finally, return to the original directory
cd $originalDir

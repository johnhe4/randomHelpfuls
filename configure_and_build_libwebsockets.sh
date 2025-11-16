#!/bin/bash

# This is a helper script to configure and build libwebsockets.
# Get the code then run this script:
#   git clone git@github.com:warmcat/libwebsockets.git
#
# Tested with branch v4.3-stable
# For servers that accept clients without Sec-WebSocket-Protocol, you MUST use hash 55135591 or later:
#   https://github.com/warmcat/libwebsockets/issues/3436
#
# NOTES:
#
########## BEGIN USER EDIT SECTION #############

# Location of the source
srcDir=~/code/libwebsockets

# Build type
#  Debug
#  Release
#  MinSizeRel
BUILD_TYPE=MinSizeRel

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
-DLWS_ROLE_MQTT=ON \
-DLWS_WITH_HTTP_STREAM_COMPRESSION=OFF \
-DLWS_WITH_HTTP_BASIC_AUTH=ON \
-DLWS_WITH_HTTP_DIGEST_AUTH=OFF \
-DLWS_WITH_HTTP_UNCOMMON_HEADERS=OFF \
-DLWS_WITH_SYS_STATE=OFF \
-DLWS_WITH_SYS_SMD=OFF \
-DLWS_WITH_SYS_FAULT_INJECTION=OFF \
-DLWS_WITH_UPNG=OFF \
-DLWS_WITH_GZINFLATE=OFF \
-DLWS_WITH_JPEG=OFF \
-DLWS_WITH_DLO=OFF \
-DLWS_WITH_SECURE_STREAMS=OFF \
-DLWS_WITH_SSL=ON \
-DLWS_WITH_MBEDTLS=OFF \
-DLWS_WITH_CYASSL=OFF \
-DLWS_WITH_WOLFSSL=OFF \
-DLWS_SSL_CLIENT_USE_OS_CA_CERTS=ON \
-DLWS_WITH_TLS_SESSIONS=ON \
-DLWS_WITH_EVLIB_PLUGINS=OFF \
-DLWS_WITH_STATIC=ON \
-DLWS_WITH_SHARED=OFF \
-DLWS_STATIC_PIC=ON \
-DLWS_SUPPRESS_DEPRECATED_API_WARNINGS=ON \
-DLWS_WITHOUT_BUILTIN_GETIFADDRS=OFF \
-DLWS_WITHOUT_BUILTIN_SHA1=ON \
-DLWS_SSL_SERVER_WITH_ECDH_CERT=OFF \
-DLWS_WITH_LEJP=OFF \
-DLWS_WITH_CBOR=OFF \
-DLWS_WITH_CBOR_FLOAT=OFF \
-DLWS_WITH_LHP=OFF \
-DLWS_WITH_JSONRPC=OFF \
-DLWS_WITH_DIR=OFF \
-DLWS_WITH_LEJP_CONF=OFF \
-DLWS_WITH_MINIMAL_EXAMPLES=OFF \
-DLWS_WITH_LWSAC=OFF \
-DLWS_WITH_WOL=OFF \
-DLWS_WITH_CACHE_NSCOOKIEJAR=OFF \
-DLWS_WITH_NETLINK=OFF \
-DLWS_WITH_BINDTODEVICE=OFF \
-DLWS_WITHOUT_TESTAPPS=ON \
-DLWS_WITH_NETLINK=OFF \
-DLWS_WITH_LIBCAP=OFF \
"

# These options are critical for iOS, visionOS, and Android. For reasons unknown to me,
# cmake completely ignores any prefix path given unless these are explicitly specified.
#  https://stackoverflow.com/questions/65494246/cmakes-find-package-ignores-the-paths-option-when-building-for-ios
OPTIONS="$OPTIONS \
-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH \
-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH \
-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH \
"

if [ -n "$INSTALL_PREFIX" ]; then
   OPTIONS="$OPTIONS -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX"
fi

# This hack is needed if cross-compiling because libwwebsockets runs pre-compilation checks that don't honor the prefix, leading to conflicting openssl instances being used.
# The initial error is rather hidden but can be seen in the configure output as:
# ...
#  -- Looking for HMAC_CTX_new
#  -- Looking for HMAC_CTX_new - not found
# ...
#
# Later it will result in a compilation error along the lines of:
# ... field has incomplete type 'HMAC_CTX'
#
# Forcing these variables to the openssl instance we want seems to address the issue
CROSS_OPTIONS="$CROSS_OPTIONS -DLWS_OPENSSL_INCLUDE_DIRS=$INSTALL_PREFIX/include"
CROSS_OPTIONS="$CROSS_OPTIONS -DLWS_OPENSSL_LIBRARIES=$INSTALL_PREFIX/lib/libssl.a;$INSTALL_PREFIX/lib/libcrypto.a"
#
# Don't treat warnings as errors
#OPTIONS="$OPTIONS -DCMAKE_COMPILE_WARNING_AS_ERROR=OFF"
OPTIONS="$OPTIONS -DDISABLE_WERROR=ON"

CONFIGURE_CMD="cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE"
BUILD_CMD="make -j16"
INSTALL_CMD="sudo make install"
if [ "$BUILD_FOR" = "iphoneos" ] || [ "$BUILD_FOR" = "iphonesimulator" ] || [ "$BUILD_FOR" = "macoscatalyst" ] || [ "$BUILD_FOR" = "xros" ] || [ "$BUILD_FOR" = "xrsimulator" ]; then
   XCODE_DEV="$(xcode-select -p)"

   # Manually define this since visionOS has no equivalent check (yet)
   OPTIONS="$OPTIONS $CROSS_OPTIONS -DLWS_DETECTED_PLAT_IOS=ON -DLWS_WITH_BORINGSSL=OFF"

   if [ "$BUILD_FOR" = "iphoneos" ]; then
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS -DCMAKE_OSX_ARCHITECTURES=$ARCH"
   elif [ "$BUILD_FOR" = "iphonesimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS -DCMAKE_OSX_ARCHITECTURES=$ARCH -DCMAKE_OSX_SYSROOT=$SYSROOT"
   elif [ "$BUILD_FOR" = "macoscatalyst" ]; then
      echo NOT IMPLEMENTED
      exit 0
      #OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=$ARCH"
   elif [ "$BUILD_FOR" = "xros" ]; then
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=visionOS -DCMAKE_OSX_ARCHITECTURES=$ARCH"
   elif [ "$BUILD_FOR" = "xrsimulator" ]; then
      SYSROOT=$XCODE_DEV/Platforms/XRSimulator.platform/Developer/SDKs/XRSimulator.sdk
      OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=visionOS -DCMAKE_OSX_ARCHITECTURES=$ARCH -DCMAKE_OSX_SYSROOT=$SYSROOT"
   fi
elif [ "$BUILD_FOR" = "android" ]; then
   OPTIONS="$OPTIONS $CROSS_OPTIONS -DLWS_AVOID_SIGPIPE_IGN=ON -DLWS_WITH_BORINGSSL=ON"
   if [ "$ARCH" = "arm64" ]; then
      OPTIONS="$OPTIONS -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a"
   else
      OPTIONS="$OPTIONS -DCMAKE_ANDROID_ARCH_ABI=x86_64"
   fi
   OPTIONS="$OPTIONS -DCMAKE_SYSTEM_NAME=Android -DCMAKE_SYSTEM_VERSION=$ANDROID_SDK_VERSION -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX"
elif [ "$BUILD_FOR" = "macos" ]; then
   OPTIONS="$OPTIONS -DCMAKE_OSX_ARCHITECTURES=$ARCH -DLWS_WITH_BORINGSSL=OFF"
elif [ "$BUILD_FOR" = "win32" ]; then
   OPTIONS="$OPTIONS -DLWS_WITH_BORINGSSL=OFF"
else
   OPTIONS="$OPTIONS -DLWS_WITH_BORINGSSL=OFF"
fi

# Let's begin.
originalDir=`pwd`
cd $srcDir
mkdir -p build
cd build

# Start from scratch
rm -f CMakeCache.txt

$CONFIGURE_CMD $OPTIONS

$BUILD_CMD

$INSTALL_CMD

# Finally, return to the original directory
cd $originalDir

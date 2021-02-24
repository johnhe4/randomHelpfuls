#!/bin/bash

# This is a helper script to configure and build gRPC.

########## BEGIN USER EDIT SECTION #############

srcDir=~/code/grpc

# Let's use what we know works
git checkout tags/v1.36.0 -b v1.36.0

# I installed the dependcies manually, letting grpc build only itself
# Feature selection, each one beginning with '-D' because it's CMAKE
FEATURES=" \
-DBUILD_SHARED_LIBS=OFF \
-DgRPC_BUILD_CODEGEN=OFF \
-DgRPC_BUILD_GRPC_CPP_PLUGIN=OFF \
-DgRPC_BUILD_CSHARP_EXT=OFF \
-DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF \
-DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
-DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
-DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF \
-DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF \
-DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF \
-DgRPC_ZLIB_PROVIDER=package \
-Dprotobuf_BUILD_PROTOC_BINARIES=OFF \
-DgRPC_SSL_PROVIDER=package \
-DgRPC_ABSL_PROVIDER=module \
-DgRPC_PROTOBUF_PROVIDER=module \
-D_gRPC_CARES_LIBRARIES=cares \
-DgRPC_CARES_PROVIDER=kludge \
-DRE2_BUILD_TESTING=OFF \
"

# Release or Debug?
BUILD_TYPE="-DCMAKE_BUILD_TYPE=Release"

# iOS build? Leave empty if not
PLATFORM="iOS"

########## END USER EDIT SECTION #############

BUILD_FOR=""
OPEN_SSL=""
CARES=""
if [ "$PLATFORM" = "iOS" ]; then
   # Require more info
#   if [ "$#" -lt 3 ]; then
#      echo "Usage (if iOS): "
#      echo "   ./configure_xxx CODE_SIGN_IDENTITY PROVISIONING_PROFILE PRODUCT_BUNDLE_IDENTIFIER"
#      echo "run `security find-identity -v -p codesigning` to find a value for CODE_SIGN_IDENTITY"
#      exit 1
#   fi
#
#   echo "CODE_SIGN_IDENTITY=\"$1\""
#   echo "PROVISIONING_PROFILE=\"$2\""
#   echo "PRODUCT_BUNDLE_IDENTIFIER=\"$3\""

   BUILD_FOR="-G Xcode -DCMAKE_SYSTEM_NAME=iOS"

   # Path to openssl headers and libs.
   # I built this using https://github.com/x2on/OpenSSL-for-iPhone.git
   OPEN_SSL=" \
   -DOPENSSL_INCLUDE_DIR=/Users/john/code/OpenSSL-for-iPhone/include/ \
   -DOPENSSL_CRYPTO_LIBRARY=/Users/john/code/OpenSSL-for-iPhone/lib/libcrypto.a \
   -DOPENSSL_SSL_LIBRARY=/Users/john/code/OpenSSL-for-iPhone/lib/libssl.a \
   -DCMAKE_CXX_FLAGS='-DOPENSSL_NO_ENGINE=1' \
   "

   #   -DOPENSSL_ROOT_DIR=/Users/john/code/OpenSSL-for-iPhone/ \
#   -DOPENSSL_SSL_LIBRARY=/Users/john/code/OpenSSL-for-iPhone/lib/ \

   # Path to c-ares library
   # TODO: This is massive overkill, but I don't want to take the time to figure
   # which of these applies.
   export LIBRARY_PATH=/Users/john/code/c-ares/build/lib/Release/
   CARES=" \
   -DCMAKE_STATIC_LINKER_FLAGS=-L/Users/john/code/c-ares/build/lib/Release/ \
   -DCMAKE_SHARED_LINKER_FLAGS=-L/Users/john/code/c-ares/build/lib/Release/ \
   -DCMAKE_MODULE_LINKER_FLAGS=-L/Users/john/code/c-ares/build/lib/Release/ \
   -DCMAKE_EXE_LINKER_FLAGS=-L/Users/john/code/c-ares/build/lib/Release/ \
   "
fi

# Let's begin. First, enter the new directory
originalDir=`pwd`
cd $srcDir

# Run the configure script
cmake . $BUILD_FOR $BUILD_TYPE $OPEN_SSL $CARES $FEATURES

if [ "$PLATFORM" = "iOS" ]; then
   # Use Xcode to make and install
   xcodebuild \
   -configuration Release \
   -target grpc \
   CODE_SIGN_IDENTITY="" \
   CODE_SIGNING_REQUIRED=NO
#   CODE_SIGN_IDENTITY="$1" \
#   PROVISIONING_PROFILE="$2" \
#   PRODUCT_BUNDLE_IDENTIFIER="$3"
else
   sudo make install
fi

# Finally, return to the original directory
cd $originalDir

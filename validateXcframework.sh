#!/bin/zsh
# Validates the an XCFramework

# Specify the import name of the XCFramework
IMPORT_NAME=myFramework

# Specify the version of Xcode to compile with. Must be installed on this system!
XCODE_VER=15.2

# Specify all known variants
declare -a VARIANTS=(
   "macos,x86_64"
   "macos,arm64"
   "ios,arm64"
   "ios,arm64,simulator"
   "ios,x86_64,simulator"
   "xros,arm64"
   "xros,arm64,simulator"
   "xros,x86_64,simulator"
)

# ===================================================
# Shouldn't need to manually edit anything below this
# ===================================================

# Ensure we are using the correct version of Xcode
XCODE_VER_INS=$(xcodebuild -version | head -1 | cut -d' ' -f2)
if [ "$XCODE_VER_INS" != "$XCODE_VER" ]; then
  echo "Active XCode is $XCODE_VER_INS, but this script requires version $XCODE_VER. Please change your terminal build tools to the match $XCODE_VER and try again."
  echo "Example:"
  echo "  sudo xcode-select -s /Applications/Xcode_$XCODE_VER.app/Contents/Developer"
  exit 0
fi
echo "Active XCode version is $XCODE_VER_INS"

# Get the current swift version. This depends on the active version of xcode
SWIFT_COMPILER_VERSION_INS=$(xcrun swift -version 2>&1 | cut -d' ' -f7)
echo "Active swift compiler version is $SWIFT_COMPILER_VERSION_INS"

# Get the arguement
if [ $# -lt 1 ]; then
   echo "usage:"
   echo "   validateXcframework.sh {xcframework}"
   exit -1
fi
ROOT=$1

# Verify the directory exists (not a regular file)
if [ ! -d $ROOT ]; then
   echo "$ROOT does not exist or is not a directory"
   exit -1
fi

# For each known variant
for VARIANT in "${VARIANTS[@]}"; do
   # Find matching directories
   IFS="," read -r OS ARCH SIMULATOR <<< "$VARIANT"
   if [ -z "$SIMULATOR" ]; then
      MATCHES=$(find $ROOT -name "$OS*$ARCH*" ! -name "*simulator*")
   else
      MATCHES=$(find $ROOT -name "$OS*$ARCH*simulator")
   fi

   # We should only find one match
   NUM_MATCHES=$(echo "$MATCHES" | wc -l)
   if [ $NUM_MATCHES -eq 0 ]; then
      echo "XCFramework is missing implementation for $OS $ARCH"
      exit -1
   fi
   if [ $NUM_MATCHES -ne 1 ]; then
      echo "validation script failed; found multiple implementations for $OS $ARCH. This may or may not represent an issue with the XCFramework"
      exit -1
   fi

   # Verify the binary has the correct architecture
   BINARY_ARCHS=$(lipo -info "$MATCHES/$IMPORT_NAME.framework/$IMPORT_NAME" | cut -d':' -f 3)
   if [[ $BINARY_ARCHS != *"$ARCH"* ]]; then
      echo "XCFramework does not have binary implementation for $OS $ARCH, but it does have the appropriate directory"
      exit -1
   fi

   # Verify the correct compiler was used when building
   SWIFT_COMPILER_VERSION_BUILT=$(grep -r "swift-compiler-version" $MATCHES | awk '{print $6}' | uniq)
   if [ "$SWIFT_COMPILER_VERSION_INS" != "$SWIFT_COMPILER_VERSION_BUILT" ]; then
      echo "Active swift compiler version is $SWIFT_COMPILER_VERSION_INS, but $IMPORT_NAME.xcframework for $OS $ARCH was built with version $SWIFT_COMPILER_VERSION_BUILT"
      exit -1
   fi
   echo "$IMPORT_NAME.xcframework for $OS $ARCH was built with swift version $SWIFT_COMPILER_VERSION_BUILT"
done

echo "XCFramework is valid"

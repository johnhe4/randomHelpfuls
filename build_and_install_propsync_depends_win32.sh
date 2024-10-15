#!/bin/bash

# This is a helper script to configure and build propsync dependencies for Windows.
# It runs in git-bash and uses vcpkg to manage dependencies.
# 1. Install git for windows. This should also install git-bash
#   https://git-scm.com/downloads
# 2. From git-bash, clone randomHelpfuls:
#   git clone https://github.com/johnhe4/randomHelpfuls.git
# 3. Install vcpkg:
#   git clone https://github.com/microsoft/vcpkg.git
#   .\vcpkg\bootstrap-vcpkg.bat
# 4. Run the build/install script from an administrator git-bash:
#   build_and_install_propsync_depends_win32.sh

# Select CPU/linkage/CRT triplet. Change only if you know what you are doing
HOST_TRIPLET=x64-windows
TARGET_TRIPLET=x64-windows-static-md

# Verify vcpkg is installed, fail if not
if ! command -v vcpkg &> /dev/null; then
   echo "vcpkg is not installed"
   exit 1
fi

# Install packages for configuring. These might not be used for linking
vcpkg install vcpkg-cmake:$HOST_TRIPLET
vcpkg install flatbuffers:$HOST_TRIPLET
vcpkg install pkgconf:$HOST_TRIPLET

# Install packages for building/linking
vcpkg install cli11:$TARGET_TRIPLET
vcpkg install nlohmann-json:$TARGET_TRIPLET
vcpkg install libyaml:$TARGET_TRIPLET
vcpkg install flatbuffers:$TARGET_TRIPLET
vcpkg install curl:$TARGET_TRIPLET
vcpkg install libxml2[core]:$TARGET_TRIPLET
vcpkg install librabbitmq:$TARGET_TRIPLET
vcpkg install zeromq:$TARGET_TRIPLET
vcpkg install replxx:$TARGET_TRIPLET
vcpkg install python3:$TARGET_TRIPLET
vcpkg install catch2:$TARGET_TRIPLET


# Update the VCPKG environment variable for the user
VCPKG_EXE=`where vcpkg.exe`
VCPKG_ROOT=`dirname "$VCPKG_EXE"`
VCPKG_ROOT_CYGPATH=`cygpath $VCPKG_ROOT`
setx VCPKG_ROOT "$VCPKG_ROOT"

# Ensure flatbuffers tools directory is in our path
FLATBUFFERS_TOOLS_CYGPATH="$VCPKG_ROOT_CYGPATH/installed/$HOST_TRIPLET/tools/flatbuffers"
FLATBUFFERS_TOOLS=`cygpath -w $FLATBUFFERS_TOOLS_CYGPATH`
if [[ "$PATH" != *"$FLATBUFFERS_TOOLS_CYGPATH"* ]]; then
  echo "!!!!"
  echo "Please add '$FLATBUFFERS_TOOLS' to the PATH environment variable (user or system)"
  echo "!!!!"
fi

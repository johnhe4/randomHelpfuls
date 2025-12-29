#!/bin/bash

# This is a helper script to configure and build propsync dependencies for all supported devices.
# 1. Ensure you have randomHelpfuls cloned on your machine:
#   git clone https://github.com/johnhe4/randomHelpfuls.git
# 2. Set SCRIPTS_DIR to the randomHelpfuls location
# 3. Uncomment the rows in each dependency for your target platform/architecture.
# 4. (Optional). You may provide a 3rd argument representing the prefix (default is /usr/local).
# 5. Run the script. Libraries should install to their own directories under `{prefix}/{platform}_{architecture}`

# Location of the source repository
SCRIPTS_DIR=~/code/randomHelpfuls

# json
# $SCRIPTS_DIR/configure_and_build_json.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_json.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_json.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_json.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_json.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_json.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_json.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_json.sh xrsimulator arm64
# $SCRIPTS_DIR/configure_and_build_json.sh android arm64

# libyaml
# $SCRIPTS_DIR/configure_and_build_libyaml.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh xrsimulator arm64
# SCRIPTS_DIR/configure_and_build_libyaml.sh android arm64

# libxml2
# $SCRIPTS_DIR/configure_and_build_libxml2.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh xrsimulator arm64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh android arm64

# flatbuffers
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh xrsimulator arm64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh android arm64

# openssl
# $SCRIPTS_DIR/configure_and_build_openssl.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_openssl.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_openssl.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_openssl.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_openssl.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_openssl.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_openssl.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_openssl.sh xrsimulator arm64
# $SCRIPTS_DIR/configure_and_build_boringssl.sh android arm64

# curl
# $SCRIPTS_DIR/configure_and_build_libcurl.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh xrsimulator arm64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh android arm64

# rabbitmq
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh xrsimulator arm64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh android arm64

# libzmq
# $SCRIPTS_DIR/configure_and_build_libzmq.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh xrsimulator arm64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh android arm64

# libwebsockets
# $SCRIPTS_DIR/configure_and_build_libwebsockets.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_libwebsockets.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_libwebsockets.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_libwebsockets.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_libwebsockets.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_libwebsockets.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_libwebsockets.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_libwebsockets.sh xrsimulator arm64
# $SCRIPTS_DIR/configure_and_build_libwebsockets.sh android arm64

# replxx (not for mobile devices)
# $SCRIPTS_DIR/configure_and_build_libreplxx.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_libreplxx.sh macos x86_64
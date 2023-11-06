#!/bin/bash

# This is a helper script to configure and build propsync dependencies for all supported Apple devices.
# A common approach is to set the prefix to /usr/local for the native OS/arch of your machine, and leave all others to default.

# Location of the source
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

# libyaml
# $SCRIPTS_DIR/configure_and_build_libyaml.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_libyaml.sh xrsimulator arm64

# libxml2
# $SCRIPTS_DIR/configure_and_build_libxml2.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_libxml2.sh xrsimulator arm64

# flatbuffers
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_flatbuffers.sh xrsimulator arm64

# openssl
# $SCRIPTS_DIR/configure_and_build_openssl.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_openssl.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_openssl.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_openssl.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_openssl.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_openssl.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_openssl.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_openssl.sh xrsimulator arm64

# curl
# $SCRIPTS_DIR/configure_and_build_libcurl.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_libcurl.sh xrsimulator arm64

# rabbitmq
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_librabbitmq.sh xrsimulator arm64

# libzmq
# $SCRIPTS_DIR/configure_and_build_libzmq.sh macos arm64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh macos x86_64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh macoscatalyst x86_64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh iphoneos arm64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh iphonesimulator arm64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh iphonesimulator x86_64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh xros arm64
# $SCRIPTS_DIR/configure_and_build_libzmq.sh xrsimulator arm64

# replxx (not for mobile devices)
$SCRIPTS_DIR/configure_and_build_libreplxx.sh macos arm64
#$SCRIPTS_DIR/configure_and_build_libreplxx.sh macos x86_64
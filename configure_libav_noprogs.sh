#!/bin/bash

# John Harrison
# February 1, 2016
# Kushal Azim
# Oct 9, 2018
# Changes:
#   1. Removed --enable-small,
#   2. Added --prefix=.
#   3. Added --enable-lto
# This is a helper script to configure libav. THIS DOES NOT BUILD ANYTHING!
# It will enter the source directory and run the configuration script. It will
# then return to this directory and you will have to manually enter the libav
# directory type 'make'.
libavDir=~/code/libav-12.3

# Only needed if compiling Android
NDK=~/code/android-ndk-r20b

# Kushal: Added specific branch checkout
# branch_or_release_name=n4.0.2 # Discuss with John or Durga about branch change.
# if [ -d .git ]; then
#     echo "Changing to branch/tag: $branch_or_release_name, Make sure you pulled the latest change."
#     git checkout $branch_or_release_name
# fi
# Read this for more information on building for windows using MSVC:
#   https://libav.org/documentation/platform.html#Microsoft-Visual-C_002b_002b-or-Intel-C_002b_002b-Compiler-for-Windows

# Set the HSOT OS (the OS currently running this script). Options are:
#   WIN64
#   LINUX64
#   MACOS
HOST_OS=MACOS

# Set the TARGET OS (the OS we are building for). Options are:
#   WIN64
#   LINUX64
#   LINUXARM
#   MACOS
TARGET_OS=ARMV7A

# Set to 1 for Debug build, 0 for release build
DEBUG=0

CFLAGS=""
LDFLAGS=""
OS_SPECIFIC=""

# Let's begin. First, enter the new directory
originalDir=`pwd`
cd $libavDir

# Depending on the host OS
case "$HOST_OS" in
	WIN64)
		case "$TARGET_OS" in
			WIN64)
				OS_SPECIFIC="--toolchain=msvc"
				CFLAGS+=""
				LDFLAGS+="-nodefaultlib:LIBCMT "
			;;
		esac
	;;
	LINUX64)
		case "$TARGET_OS" in
			WIN64)
				# Select the mingw toolchain
				# x86 is probably i686-w64-mingw32-
				# x64 is probably x86_64-w64-mingw32-
				OS_SPECIFIC="--cross-prefix=x86_64-w64-mingw32- --arch=x86 --target-os=mingw32 --enable-w32threads"
				CFLAGS+="-D__USE_MINGW_ANSI_STDIO=0 "
			;;
			LINUX64)
				export CFLAGS="-I /usr/include"
				export LDFLAGS="-L /usr/lib/x86_64-linux-gnu"
				OS_SPECIFIC="--arch=x86 --enable-pic"
				CFLAGS+="-mcmodel=large "
			;;
			LINUXARM)
				echo "Linux ARM not supported yet! But you are welcome to put it in ;)"
			;;
		esac
        ;;
	MACOS)
		case "$TARGET_OS" in
			ARMV7A)
				# JH: This is a purely llvm compilation, gcc isn't used at all.
				# I found lots of older "gcc" ways of doing this but this is the
				# most modern and best way, methinks.
				SYSROOT="${NDK}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot"
				TOOLCHAIN="${NDK}/toolchains/llvm/prebuilt/darwin-x86_64"
				CFLAGS="--target=armv7-linux-androideabi26,--gcc-toolchain=$TOOLCHAIN,mfloat-abi=softfp"
				OS_SPECIFIC="--disable-runtime-cpudetect \
					--arch=arm \
					--cpu=armv7-a \
					--cc=$TOOLCHAIN/bin/armv7a-linux-androideabi26-clang \
					--target-os=android \
					--disable-symver \
					--sysroot=$SYSROOT \
					--enable-cross-compile"
			;;
		esac
	;;
esac

if [ $DEBUG == 1 ]; then
	OPTIMIZATIONS="--disable-optimizations --enable-debug=3"
else
	#OPTIMIZATIONS="--enable-runtime-cpudetect --enable-small --disable-debug"
	# Kushal: I removed the --enable-small for binaries to execute faster
    #OPTIMIZATIONS="--enable-runtime-cpudetect  --disable-debug" THIS BREAKS CROSS-COMPILATION!!!
	OPTIMIZATIONS="--disable-debug"
fi

# Enabled features #Kushal: Added mpegts #boxu: Added mjpeg
ENABLED="--enable-protocol=file
--enable-avformat
--enable-avcodec
--enable-decoder=h264
--enable-decoder=aac
--enable-decoder=hevc
--enable-muxer=mp4
--enable-muxer=mpegts
--enable-muxer=hls
--enable-muxer=flv
--enable-demuxer=aac
--enable-demuxer=h264
--enable-demuxer=hevc
--enable-parser=mpeg4video
--enable-parser=aac
--enable-parser=h264
--enable-parser=hevc
--enable-zlib"

# Disabled features # Kushal: Enabled program
DISABLED="--disable-everything
--disable-programs
--disable-symver
--disable-encoders
--disable-decoders
--disable-muxers
--disable-demuxers
--disable-parsers
--disable-bsfs
--disable-protocols
--disable-indevs
--disable-outdevs
--disable-filters
--disable-doc
--disable-avdevice
--disable-avfilter
--disable-hwaccels"

# Temporary features that should be removed before checking in this file
TEMPORARY=""
#TEMPORARY="--enable-version3 --enable-encoder=libvo_aacenc --enable-libvo-aacenc"
#CFLAGS+="-IC:/code/3D4U/LiveEvent/include "

# If using librtmp, it needs to be downloaded and compiled on linux for either platform
# make sys=mingw for windows
# make sys=posix for linux 
# NOTE: This last part didn't actually work :)
#LDFLAGS+="-L/root/Downloads/rtmpdump-2.3/librtmp"

# Run the configure script
# Kushal: Added --prefix=. --enable-lto
ARGS="$OS_SPECIFIC \
	$OPTIMIZATIONS \
	$DISABLED $ENABLED \
	--enable-lto \
	--disable-static \
	--enable-shared \
	--extra-cflags=\"$CFLAGS\" \
	--extra-ldflags=\"$LDFLAGS\" \
	$TEMPORARY"
./configure $ARGS
echo $ARGS

# Finally, return to the original directory
cd $originalDir


#!/bin/bash
# John Harrison <john.a.harrison@intel.com>
# August 2020
#
# I figured out how to do this by opening up Instruments and recording file I/O for a onenote session
#
# Make sure onenote (the desktop app) is closed before running this.
#
# This will use the helpful 'trash' command if installed, which will move to the trash instead of removing forever.
# Use 'brew intall trash' to install if you want this.
# 'rm' is used if 'trash' is not installed, removing these files forever. This is almost certainly okay, but you never know

DIR1="~/Library/Containers/com.microsoft.onenote.mac/Data/Library/Application Support/Microsoft/Office/16.0"
DIR2="~/Library/Containers/com.microsoft.onenote.mac/Data/Library/Application Support/Microsoft User Data/OneNote/15.0"
if ! command -v trash &> /dev/null; then
   rm -rf "$DIR1" "$DIR2"
else
   trash -F "$DIR1" "$DIR2" &> /dev/null
fi

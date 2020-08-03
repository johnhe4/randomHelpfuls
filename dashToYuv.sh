#!/bin/bash

FFMPEG=~/code/FFmpeg/ffmpeg
INPUT_URL=https://livesim.dashif.org/livesim/chunkdur_1/ato_7/testpic4_8s/Manifest.mpd

# Set the logging level to one of the following:
#  quiet      Show nothing at all; be silent.
#  panic      Only show fatal errors which could lead the process to crash, such as an assertion failure. This is not currently used for anything.
#  fatal      Only show fatal errors. These are errors after which the process absolutely cannot continue.
#  error      Show all errors, including ones which can be recovered from.
#  warning    Show all warnings and errors. Any message related to possibly incorrect or unexpected events will be shown.
#  info       Show informative messages during processing. This is in addition to warnings and errors. This is the default value.
#  verbose    Same as info, except more verbose.
#  debug      Show everything, including debugging information.
#  trace      
LOG_LEVEL=debug

# Create an output folder
mkdir -p yuv_frames

# STEP 1
#Create YUV files from the input
$FFMPEG -loglevel $LOG_LEVEL -i $INPUT_URL -c:v rawvideo -pix_fmt yuv420p -f segment -segment_time 0.01 -frame_pts 1 yuv_frames/frames%04d.yuv


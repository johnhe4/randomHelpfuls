#!/bin/bash

FFMPEG=ffmpeg
INPUT_DIR=~/Downloads/v4TestData/cardinals_cam4
FPS=30
WIDTH=5120
HEIGHT=3072

# STEP 1
# Create an ffmpeg input list file
inputFileList=($INPUT_DIR/*)
echo "# This is a generated input file list for FFMPEG" > inputFiles.txt
for filename in "${inputFileList[@]}"; do
   echo "file '$filename'" >> inputFiles.txt
done

# Create an output folder
mkdir -p yuv_frames

# STEP 2
#Create YUV files the input
$FFMPEG -analyzeduration 2147483647 -probesize 2147483647 -f concat -safe 0 -i inputFiles.txt -c:v rawvideo -pix_fmt yuv420p -f segment -segment_time 0.01 yuv_frames/frames%04d.yuv -loglevel debug


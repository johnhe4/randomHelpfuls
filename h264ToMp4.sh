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

# STEP 2
# Create an MP4 from the h.264 GOPs
$FFMPEG -f concat -safe 0 -i inputFiles.txt -c:v copy -s $WIDTHx$HEIGHT -framerate 30 out.mp4


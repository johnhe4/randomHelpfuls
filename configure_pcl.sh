#!/bin/bash

# This is a helper script to configure PCL. THIS DOES NOT BUILD ANYTHING!
# It will enter the source directory and run the configuration script. It will
# then return to this directory and you will have to manually enter the ffmpeg
# directory type 'make'.
#
# You can read more about configurinng PCL here:
#   https://pcl-tutorials.readthedocs.io/en/latest/building_pcl.html#building-pcl

########## BEGIN USER EDIT SECTION #############

srcDir=~/code/pcl

# Featur selection, each one beginning with '-D' because it's CMAKE
PCL_FEATURES=" \
-DBUILD_visualization=OFF \
-DBUILD_keypoints=OFF \
-DBUILD_range_image=OFF \
-DBUILD_registration=OFF \
-DBUILD_sample_consensus=OFF \
-DBUILD_segmentation=OFF \
-DBUILD_surface=ON \
"

# Release or Debug?
BUILD_TYPE="-DCMAKE_BUILD_TYPE=Release"

########## END USER EDIT SECTION #############

# Let's begin. First, enter the new directory
originalDir=`pwd`
cd $srcDir

# Out-of-tree build
mkdir -p build
cd build 

# Run the configure script
cmake .. $PCL_FEATURES $BUILD_TYPE

# Finally, return to the original directory
cd $originalDir

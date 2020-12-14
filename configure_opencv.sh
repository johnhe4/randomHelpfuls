#!/bin/bash

# This is a helper script to configure opencv for python3 on mac.
# THIS DOES NOT BUILD ANYTHING!
# It will enter the source directory and run the configuration script. It will
# then return to this directory and you will have to manually enter the 
# directory type 'make'.
#
# IMPORTANT NOTE: after making and installing opencv, you may need to manually
# create a symbolic link. I was using pyenv and had to do this after installation:
#   ln -s /usr/local/lib/python3.9/site-packages/cv2/python-3.9/cv2.cpython-39-darwin.so `pyenv prefix`/lib/python3.9/site-packages/cv2.so
########## BEGIN USER EDIT SECTION #############

srcDir=~/code/opencv
python3Version=3.9
python3Prefix=`pyenv prefix`

# Python 3 build options, each one beginning with '-D' because it's CMAKE
PYTHON3_OPTIONS=" \
-DBUILD_opencv_python3=ON \
-DPYTHON3_LIBRARY=$python3Prefix/lib/libpython$python3Version.dylib \
-DPYTHON3_INCLUDE_DIR=$python3Prefix/include/python$python3Version \
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
cmake .. $PYTHON3_OPTIONS

# Finally, return to the original directory
cd $originalDir

#!/bin/bash
#
# Prints bitcode version (but can be modified to print other stuff) for all .a files in a directory
dir=~/code/libpropsync/iosLibs

for f in $dir/*.a; do
   filename=${f##*/}
   filename=${filename%.*}
   llvm-objcopy --dump-section=__LLVM,__bitcode=$filename.bc $f
   echo "$filename:"
   llvm-bcanalyzer --dump $filename.bc | grep version
done

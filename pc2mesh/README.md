# pc2mesh
Converts a point cloud to a triangulated mesh. Assuming you can build against PCL and its dependencies, this code should be cross-platform.

## Input
Accepts a single DTM file, where the data is a comma-separated value (CSV) ASCII format.

## Output
Outputs sa triangulated mesh as PLY (ASCII) file. PCL does all the heavy lifting here.

## Dependencies
### CLI11
[CLI11](https://github.com/CLIUtils/CLI11) is a header-only open source library used for command-line parsing.

### PCL
[PCL](https://github.com/PointCloudLibrary/pcl) is an open source library for doing stuff with point clouds. PCL must be built with the following features:
 - common
 - io
 - kdtree
 - features
 - search 
 - surface
 - octree

PCL depends on [VTK](https://github.com/Kitware/VTK), but the latest versions of VTK don't seem to work correctly with PCL. I had success using VTK version 8.2.

## Build
```
cd <root>/pc2mesh
mkdir build
cd build
cmake ..
make
```
For Xcode, use `cmake .. -G Xcode`, then open the .xcproj file.

For Visual Studio, use `cmake .. -G "Visual Studio"`, then open the .sln file.

Once built, the resulting `pc2mesh` binary will output to `./bin/<platform>`.
# pc2mesh
Converts a point cloud to a triangulated mesh. Assuming you can build against PCL and its dependencies, this code should be cross-platform.

## Usage 
```
pc2mesh [OPTIONS]

Options:
  -h,--help                   Print this help message and exit
  -i,--input TEXT REQUIRED    Input point cloud file {.dtm|.las|.laz})                              
  -o,--output TEXT REQUIRED   Output mesh as PLY file. Will also output a point cloud PLY in case it's useful                              
  --lat FLOAT                 Specifiy a reference latitude, used for --distance                              
  --long FLOAT                Specifiy a reference longitude, used for --distance                              
  -d,--distance FLOAT=0       Only include points within --distance of specified --lat and --long. Always in meters
``` 

## Output
Outputs a triangulated mesh as a PLY (ASCII) file. PCL does the heavy lifting.

## Dependencies
### CLI11
[CLI11](https://github.com/CLIUtils/CLI11) is a header-only open source library used for command-line parsing.

### PROJ
[PROJ](https://github.com/OSGeo/PROJ/tree/7.2) is a generic coordinate transformation software, that transforms coordinates from one coordinate reference system (CRS) to another.

### libLAS
[libLAS](https://github.com/libLAS/libLAS) is a C/C++ library for reading and writing the very common LAS LiDAR format

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

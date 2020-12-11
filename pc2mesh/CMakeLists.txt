cmake_minimum_required( VERSION 3.14 )

# Apple stuff to avoid a warning about rpaths
cmake_policy( SET CMP0042 NEW )

# Target the 64-bit compiler on Windows. We assume 64-bit for everything
# and no effort has been made to support 32-bit.
if(WIN32)
   set( CMAKE_GENERATOR_PLATFORM x64 CACHE INTERNAL "Force 64-bit compilation" )
endif()

# Main project
project( pc2mesh )

# C++ settings
set( CMAKE_CXX_STANDARD 14 )
set( CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")

# Use PCL for the heavy lifting
# PCL has a cmake bug. When fixed, remove the following 3 lines (https://github.com/PointCloudLibrary/pcl/issues/3680)
if(NOT DEFINED CMAKE_SUPPRESS_DEVELOPER_WARNINGS)
     set(CMAKE_SUPPRESS_DEVELOPER_WARNINGS 1 CACHE INTERNAL "No dev warnings")
endif()
find_package( PCL REQUIRED COMPONENTS common io kdtree features search surface octree )

# Use CLI11 for argument parsing
find_package( CLI11 REQUIRED )

# LAS read suppor using libLAS
find_package( libLAS REQUIRED )

# PROJ, because required by libLAS and it is used for coordinate transformations
find_package( PROJ )

if (APPLE)
   if (CMAKE_SYSTEM_NAME STREQUAL "iOS")
      set( PLATFORM_STRING "iphoneos" )
   else()
      set( PLATFORM_STRING "macosx" )
   endif()
   
   # Allow libs not part of this build to be used for linking
   cmake_policy( SET CMP0079 NEW )

   # Mac doesn't include user include directory by default, add it here
   include_directories( /usr/local/include )
elseif(WIN32)
   set( PLATFORM_STRING "win64" )
elseif(ANDROID)
   set( PLATFORM_STRING "armv7a" )
else()
   set( PLATFORM_STRING "linux" )
endif()

# Force all output binaries to a single directory.
# The generator expression is used to avoid IDEs from adding a suffix to the output path,
# such as "Debug" or "Release".
# See here for more info: https://cmake.org/cmake/help/latest/prop_tgt/LIBRARY_OUTPUT_DIRECTORY.html
set( BIN_DIR  ${PROJECT_SOURCE_DIR}/bin/${PLATFORM_STRING} )
set( CMAKE_RUNTIME_OUTPUT_DIRECTORY         ${BIN_DIR}$<0:> )
set( CMAKE_LIBRARY_OUTPUT_DIRECTORY         ${BIN_DIR}$<0:> )
set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY         ${BIN_DIR}$<0:> )

add_executable( pc2mesh main.cpp utility.hpp )
target_link_libraries( pc2mesh ${PCL_LIBRARIES} ${libLAS_LIBRARIES} ${PROJ_LIBRARIES} )

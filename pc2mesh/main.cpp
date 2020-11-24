#include <fstream>
#include <CLI/CLI.hpp>
#include <pcl/point_types.h>
#include <pcl/io/ply_io.h>
#include <pcl/io/pcd_io.h>
#include <pcl/kdtree/kdtree_flann.h>
#include <pcl/features/normal_3d.h>
#include <pcl/surface/gp3.h>
#include "utility.hpp"

struct Args
{
   std::string inputFilename;
   std::string outputFilename;
}args;

enum class FILE_TYPE
{
   DTM,
   CSV,
   UNKNOWN
};

auto DetermineFileType( std::string filename )
{
   auto returnValue = FILE_TYPE::UNKNOWN;
   auto index = filename.find_last_of( "." );
   if ( index != std::string::npos )
   {
      // Get the filename extension, lower case, don't include the period
      auto filenameExtension = filename.substr( index + 1 );
      std::transform( filenameExtension.begin(), filenameExtension.end(), filenameExtension.begin(),
         [](unsigned char c)
         {
            return std::tolower( c );
         } );

      if ( filenameExtension == "dtm" )
         returnValue = FILE_TYPE::DTM;
      else if ( filenameExtension == "csv" || filenameExtension == "txt" )
         returnValue = FILE_TYPE::CSV;
   }     

   return returnValue;
}
auto ReadFileDTM( std::ifstream & file )
{
   // DTM files are CSV files where each row is of the form:
   // <index>, <X>, <Y>, <Z>, "DTM"
   
   pcl::PointCloud<pcl::PointXYZ> returnValue;

   while ( !file.eof() )
   {
      pcl::PointXYZ point;
      std::string cell;
      int i = 0;
      while ( std::getline( file, cell, ',' ) )
      {
         if ( i > 0 )
         {
            point.data[ i - 1 ] = (float)strtod( cell.c_str(), nullptr );
         }
         
         if ( i == 3 )
            break;
         
         ++i;
      }

      returnValue.push_back( point );
   }

   return returnValue;
}
auto ReadFile( std::string filename )
{
   pcl::PointCloud<pcl::PointXYZ> returnValue;
    
   filename = ExpandTilde( filename );

   std::ifstream file( filename );
   if ( !file.good() )
   {
      std::cout << "Could not open file: " << strerror( errno ) << std::endl;
   }
   else
   {
      auto fileType = DetermineFileType( filename );
      
      switch ( fileType )
      {
         case FILE_TYPE::DTM: returnValue = ReadFileDTM( file ); break;
         case FILE_TYPE::CSV:
         default: break;
      }

      file.close();
   }
   
   return returnValue;
}
int main( int argc, char *argv[] )
{
   // Process command-line arguments
   CLI::App app{ "App description" };
   
   app.add_option( "-i,--input", args.inputFilename, "Input point cloud (.dtm)\n" )->required();
   app.add_option( "-o,--output", args.outputFilename, "Output mesh as PLY file\n" )->required();
   
   // The default arguments are files or a directory
   //std::vector< std::string > filesOrDirectory;
   //app.add_option_function< std::vector< std::string > >( "files-or-directory", ParseFilesOrDirectory, "Input files or directory" )->excludes( streamOption );

   CLI11_PARSE( app, argc, argv );

   // Read in the file, return a PCL object representing a point cloud
   const auto cloud = std::make_shared<pcl::PointCloud<pcl::PointXYZ>>( ReadFile( args.inputFilename ) );

   // Normal estimation*
   pcl::NormalEstimation<pcl::PointXYZ, pcl::Normal> n;
   pcl::PointCloud<pcl::Normal> normals;
   auto tree = std::make_shared<pcl::search::KdTree<pcl::PointXYZ>>();
   tree->setInputCloud( cloud );
   n.setInputCloud( cloud );
   n.setSearchMethod( tree );
   n.setKSearch( 20 );
   n.compute( normals );
   // normals should not contain the point normals + surface curvatures

   // Concatenate the XYZ and normal fields*
   auto cloud_with_normals = std::make_shared<pcl::PointCloud<pcl::PointNormal>>();
   pcl::concatenateFields( *cloud, normals, *cloud_with_normals );
   // cloud_with_normals = cloud + normals

   // Create search tree*
   auto tree2 = std::make_shared<pcl::search::KdTree<pcl::PointNormal>>();
   tree2->setInputCloud( cloud_with_normals );
   
   // Initialize objects
   pcl::GreedyProjectionTriangulation<pcl::PointNormal> gp3;
   pcl::PolygonMesh triangles;
   
   // Set the maximum distance between connected points (maximum edge length)
   gp3.setSearchRadius( 0.025 );
  
   // Set typical values for the parameters
   gp3.setMu( 2.5 );
   gp3.setMaximumNearestNeighbors( 100 );
   gp3.setMaximumSurfaceAngle( M_PI/4 ); // 45 degrees
   gp3.setMinimumAngle( M_PI/18 ); // 10 degrees
   gp3.setMaximumAngle( 2 * M_PI/3 ); // 120 degrees
   gp3.setNormalConsistency( false );

   // Get result
   gp3.setInputCloud( cloud_with_normals );
   gp3.setSearchMethod( tree2 );
   gp3.reconstruct( triangles );

   // Additional vertex information
   std::vector<int> parts = gp3.getPartIDs();
   std::vector<int> states = gp3.getPointStates();
   
   // Save as PLY
   pcl::io::savePLYFile( ExpandTilde( args.outputFilename ), triangles );
   
   return 0;
}

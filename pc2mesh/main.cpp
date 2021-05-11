#include <fstream>
#include <CLI/CLI.hpp>
#include <pcl/point_types.h>
#include <pcl/io/ply_io.h>
#include <pcl/io/pcd_io.h>
#include <pcl/kdtree/kdtree_flann.h>
#include <pcl/features/normal_3d.h>
#include <pcl/surface/gp3.h>
#include <liblas/liblas.hpp>
#include <proj.h>
#include "utility.hpp"

struct Args
{
   std::string inputFilename;
   std::string outputFilename;
   double latitude = 0.;
   double longitude = 0.;
   double searchRadius = 0.;
   std::string transform = "";
}args;

enum class FILE_TYPE
{
   DTM,
   CSV,
   LAS,
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
      else if ( filenameExtension == "las" )
         returnValue = FILE_TYPE::LAS;
   }     

   return returnValue;
}
auto ReadFileDTM( std::ifstream & file )
{
   // DTM files are CSV files where each row is of the form:
   // <index>, <X>, <Y>, <Z>, "DTM"
   
   pcl::PointCloud<pcl::PointXYZ> returnValue;

   std::array<double, 3> transform = {1,1,1};
   if ( args.transform != "" )
   {
      std::istringstream is(args.transform);
      std::vector< std::string > tokens;
      std::string token;
      while ( getline( is, token, ',') )
         if ( token.size() )
            tokens.emplace_back( token );

      int index = 0;
      for ( auto token : tokens )
      {
         transform[index++] = std::strtod(token.c_str(), nullptr);
         if ( index == 3 )
            break;
      }
   }

   while ( !file.eof() )
   {
      pcl::PointXYZ point;
      std::string cell;
      int i = 0;
      while ( std::getline( file, cell, ',' ) )
      {
         if ( i > 0 )
         {
            point.data[ i - 1 ] = (float)strtod( cell.c_str(), nullptr ) * transform[i - 1];
         }
         
         if ( i == 3 )
            break;
         
         ++i;
      }

      returnValue.push_back( point );
   }

   return returnValue;
}
auto ReadFileLAS( std::ifstream & file )
{
   // Use libLAS: https://liblas.org/tutorial/cpp.html#reading-las-data-using-liblas-reader
   
   pcl::PointCloud<pcl::PointXYZ> returnValue;
   
   // Create a libLAS reaader
   liblas::ReaderFactory f;
   liblas::Reader reader = f.CreateWithStream( file );
   
   // Get header information
   auto & header = reader.GetHeader();
   std::cout << header.GetPointRecordsCount() << " points total\n";
   
   // If we are filtering
   static Eigen::Vector2d referencePoint = { 0.f, 0.f };
   if ( args.searchRadius > 0. &&
       args.latitude != 0. &&
       args.longitude != 0 )
   {
      std::cout << "Filtering out points more than " << args.searchRadius << "m from reference " << args.latitude << "," << args.longitude << "\n";
      
      // Get the SRS information
      const auto & srs = header.GetSRS();
      
      // Get the proj coordinate string
      std::string srcProjString = srs.GetProj4();
      
      // Create a proj transformation object. This will transform our reference
      // coordinate to coordinates in the file's coordinate system.
      auto transform = proj_create_crs_to_crs( nullptr,
         "+proj=latlong +datum=WGS84 ",
         srcProjString.c_str(),
         nullptr );
      if ( !transform )
      {
         std::cout << proj_errno_string( proj_errno( transform ) ) << std::endl;
         return returnValue;
      }
      
      // Perform the transformation
      PJ_COORD referenceCoord = { .lp = { args.longitude, args.latitude } };
      auto transormedReferenceCoord = proj_trans( transform,
         PJ_FWD,
         referenceCoord );
      if ( proj_errno( transform ) )
      {
         std::cout << proj_errno_string( proj_errno( transform ) ) << std::endl;
         return returnValue;
      }
      
      // Update our reference point
      referencePoint.x() = transormedReferenceCoord.v[0];
      referencePoint.y() = transormedReferenceCoord.v[1];
      
      // Update our units multiplier. It would be nice of proj would provide this,
      // but I didn't find any accessor for this. So parsing here.
      // It may be possible to use the GeoKey 'ProjLinearUnitSizeGeoKey' from the header to achieve this,
      // but not sure how reliable or available that information is.
      double unitsMultiplier = 1.;
      auto startPos = srcProjString.find( "+units=" );
      if ( startPos != std::string::npos )
      {
         auto unitStartPos = startPos + 7;
         auto endPos = srcProjString.find( " ", unitStartPos );
         std::string unitString = (endPos == std::string::npos) ?
            srcProjString.substr( unitStartPos ) :
            srcProjString.substr( unitStartPos, endPos - unitStartPos );
         
         // Handle the known types
         if ( unitString == "us-ft" )
            unitsMultiplier = 3.280833333333;
         else if ( unitString == "m" )
            unitsMultiplier = 1.;
         else
            std::cout << "Unknown units - assuming meters" << std::endl;
      }
      
      proj_destroy( transform );
      
      // Create a new filter class and set it
      class MyFilter : public liblas::FilterI
      {
      public:
         MyFilter( double searchRadius )
            : FilterI( eInclusion ),
             _searchRadius( searchRadius ){}
         virtual bool filter( const liblas::Point & lasPoint )
         {
            // Filter
            Eigen::Vector2d point2d( lasPoint.GetX(), lasPoint.GetY() );
            double distance = (point2d - referencePoint).norm();
            return distance < _searchRadius;
         }
         private: double _searchRadius;
      };
      std::vector< liblas::FilterPtr > filters = { boost::shared_ptr< MyFilter >( new MyFilter( args.searchRadius * unitsMultiplier ) ) };
      reader.SetFilters( filters );
   }
   
   // For each point
   while ( reader.ReadNextPoint() )
   {
      // Get the point
      liblas::Point const& lasPoint = reader.GetPoint();
      
      // Add the point
      returnValue.emplace_back( pcl::PointXYZ( float(lasPoint.GetX()),
         float(lasPoint.GetY()),
         float(lasPoint.GetZ()) ) );
   }

   std::cout << returnValue.size() << " points remain after filtering" << std::endl;
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
         case FILE_TYPE::LAS: returnValue = ReadFileLAS( file ); break;
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
   
   app.add_option( "-i,--input", args.inputFilename, "Input point cloud file {.dtm|.las|.laz})\n" )->required();
   app.add_option( "-o,--output", args.outputFilename, "Output mesh as PLY file. Will also output a point cloud PLY file in case it's useful\n" )->required();
   app.add_option( "--lat", args.latitude, "Specifiy a reference latitude, used for --distance\n" );
   app.add_option( "--long", args.longitude, "Specifiy a reference longitude, used for --distance\n" );
   app.add_option( "-d,--distance", args.searchRadius, "Only include points within --distance of specified --lat and --long. Always in meters\n", true );
   app.add_option( "--transform", args.transform, "Transformation vector as a comma-separated string in \"x,y,z\" order\n" );
   
   try
   {
      app.parse(argc, argv);
   }
   catch( const CLI::ParseError &e )
   {
      std::cout << e.what() << "\n";
      std::cout << app.help();
      return 1;
   }

   // Read in the file, return a PCL object representing a point cloud
   const auto cloud = std::make_shared<pcl::PointCloud<pcl::PointXYZ>>( ReadFile( args.inputFilename ) );
   
   // Save the point cloud in case it's useful
   std::string meshFilename = ExpandTilde( args.outputFilename );
   std::string pcFilename = ExpandTilde( args.outputFilename );
   auto pos = pcFilename.rfind( "." );
   if ( pos != std::string::npos )
      pcFilename = pcFilename.substr( 0, pos );
   pcFilename += "_pc.ply";
   pcl::io::savePLYFileBinary( pcFilename, *cloud );
   std::cout << "Saved `" << pcFilename << "' as a point cloud in case it's useful\n" << std::endl;

   // Normal estimation*
   pcl::NormalEstimation<pcl::PointXYZ, pcl::Normal> n;
   pcl::PointCloud<pcl::Normal> normals;
   auto tree = std::make_shared<pcl::search::KdTree<pcl::PointXYZ>>();
   tree->setInputCloud( cloud );
   n.setInputCloud( cloud );
   n.setSearchMethod( tree );
   n.setKSearch( 10 );
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
   gp3.setSearchRadius( args.searchRadius );
  
   // Set typical values for the parameters
   gp3.setMu( 2.5 );
   gp3.setMaximumNearestNeighbors( 100 );
   gp3.setMaximumSurfaceAngle( M_PI/2 ); // 90 degrees
   gp3.setMinimumAngle( M_PI/18 ); // 10 degrees
   gp3.setMaximumAngle( 2 * M_PI/3 ); // 120 degrees
   gp3.setNormalConsistency( true );

   // Get result
   gp3.setInputCloud( cloud_with_normals );
   gp3.setSearchMethod( tree2 );
   gp3.reconstruct( triangles );

   // Additional vertex information
   std::vector<int> parts = gp3.getPartIDs();
   std::vector<int> states = gp3.getPointStates();
   
   // Save as PLY
   pcl::io::savePLYFile( meshFilename, triangles );
   std::cout << "Saved '" << meshFilename << "' as a mesh\n";
   
   return 0;
}

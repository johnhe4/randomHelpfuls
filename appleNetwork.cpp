#if defined(WITH_APPLE_NETWORK)

#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <cstring>
#include <thread>
#include <condition_variable>
#include <mutex>

// Objective-C includes
#include <Network/Network.h>
#include <Foundation/Foundation.h>

#include "utility.hpp"
#include "propsync/propsyncTypes.h"
#include "propsync/cpp/propsyncError.hpp"
#include "propsync/cpp/serializerFactory.hpp"
#include "httpSynchronizer.hpp"

using namespace std::chrono_literals;

// This implementation uses some Objectiv-C to interop with Apple's Network framework API.
// Of note are "blocks" which you can read more about Objective-C blocks here:
//   https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithBlocks/WorkingwithBlocks.html
// TODO: May need to enable '-fblocks', see https://stackoverflow.com/questions/52683798/what-does-typedef-void-something-mean
namespace ps
{
   struct httpSynchronizer::PIMPL
   {
      std::string _url;
      std::string _initDataString;
      std::string _filename;
      size_t _bytesRead = 0;
      size_t _bytesWritten = 0;
      std::optional< std::reference_wrapper< class propProvider > > _propProvider;
      std::unique_ptr< serializer_t > _serializer;
      bool _domParsing = true;
      std::vector< unsigned char > _buffer;
      volatile bool _isOpening = false;
      volatile bool _isOpen = false;
      std::unique_ptr< property > _config;
      
      // Objective-C objects
      NSURLSession * session = nullptr;
      
//      nw_connection_t _connection = nullptr;
//      static constexpr int MIN_LENGTH = 1024;
//      static constexpr int MAX_LENGTH = UINT32_MAX;
//      using receiveDelegate = std::function<void(bool)>;
//      void receive( receiveDelegate completionCallback );
   };

   httpSynchronizer::httpSynchronizer()
      : _impl( new PIMPL() )
   {
      _impl->_serializer = ps::createSerializer( this->defaultSerializerType() );
   }
   httpSynchronizer::~httpSynchronizer()
   {
      close();
   }

   const std::string & httpSynchronizer::url() const
   {
      return _impl->_url;
   }
   void httpSynchronizer::url( std::string value )
   {
      _impl->_url = value;
   }
   const serializer_t & httpSynchronizer::serializer() const
   {
      return *_impl->_serializer;
   }
   void httpSynchronizer::serializer( std::unique_ptr< serializer_t > serializer )
   {
      _impl->_serializer = std::move(serializer);
   }
   void httpSynchronizer::initData( const std::string & initData )
   {
      _impl->_initDataString = std::ref(initData);
   }
   void httpSynchronizer::initData( std::istream & initData )
   {
      // GUARD
      if ( initData.bad() )
         throw propsyncError( API_TYPE_NAME(INVALID_SOURCE), "Bad istream" );

      // Read everything now into our member string
      _impl->_initDataString = std::string(std::istreambuf_iterator<char>(initData), {});
   }
   void httpSynchronizer::initData( const uint8_t * initData, size_t len )
   {
      this->initData( std::string(reinterpret_cast<const char *>(initData), len) );
   }
   void httpSynchronizer::domParsing( bool v )
   {
      _impl->_domParsing = v;
   }
   synchronizer & httpSynchronizer::open( std::unique_ptr< property > config )
   {
      // GUARD
      if ( isOpening() )
         return *this;
      if (!_impl->_propProvider)
         throw propsyncError("Synchronizer requires a property provider before calling open()");

      // Let's go
      _impl->_isOpen = false;
      _impl->_isOpening = true;

      // Nice cleanup
      bool failed = true;
      nw_endpoint_t endpoint = nullptr;
      nw_parameters_t params = nullptr;
      RAII raii( [this, &failed, &endpoint, &params] {
         _impl->_isOpening = false;
         if ( !failed ) _impl->_isOpen = true;
         if ( endpoint ) nw_release(endpoint);
         if ( params ) nw_release(params);
      });

      // Use the default config if not provided
      if ( !config )
         config = templateConfig();
      else
         config->upsert( templateConfig(), ps::UPSERT_POLICY::MERGE_KEEP_EXISTING );
      _impl->_config = std::move(config);

      // Use these for emulating DOM parsing
      simplePropProvider tempProps;
      std::vector< property * > parseOrder;

      std::mutex m;
      std::unique_lock<std::mutex> ul(m);
      std::condition_variable syncLock;
      std::unique_ptr<propsyncError> error = nullptr;
      auto continueWithError = [&syncLock, &error](std::string errorStr = "") {
         if ( errorStr != "" )
            error = std::make_unique<propsyncError>( errorStr );
         syncLock.notify_one();
      };

      // Create or reuse our session object
      if ( _impl->session == nullptr )
      {
         _impl->session = [NSURLSession sharedSession];
      }
      NSString *urlString = [NSString stringWithCString: _impl->_url.c_str() encoding:[NSString defaultCStringEncoding]];
      NSURLSessionDataTask *dataTask = [_impl->session dataTaskWithURL: [NSURL URLWithString: urlString] completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {

         // Guard
         if ( error ) {
            continueWithError( std::string(error.localizedDescription.UTF8String) );
            return;
         }

         // Guard
         auto httpResponse = (NSHTTPURLResponse *)response;
         if ( httpResponse.statusCode != 200 ) {
            continueWithError( std::string([NSHTTPURLResponse localizedStringForStatusCode: httpResponse.statusCode ].UTF8String) );
            return;
         }

         // All good, copy the data
         const size_t dataSize = data.length;
         const uint8_t * bytes = static_cast<const uint8_t *>(data.bytes);
         std::copy( bytes, bytes + dataSize, std::back_inserter(this->_impl->_buffer) );
         continueWithError();
      }];
      [dataTask resume];
      syncLock.wait( ul );
      if ( error ) throw *error;

// TODO: Keeping this here for 
// -----------------------------------------------
//
//      // Build and set our custom header
//      struct curl_slist * chunk = nullptr;
//      chunk = curl_slist_append( chunk, _impl->_config->at("header").valueAsString().c_str() );
//      curl_easy_setopt( _impl->_curlHandle, CURLOPT_HTTPHEADER, chunk );

//      // Build the request
//      std::stringstream request;
//      request << utility::str_toupper(_impl->_config->at("method").valueAsString()) << " " << _impl->_url.c_str() << " HTTP/1.1";
//      if ( utility::str_toupper(_impl->_config->at("method").valueAsString()) == "POST" )
//      {
////         if ( _impl->_initDataString.size() )
////            curl_easy_setopt( _impl->_curlHandle, CURLOPT_POSTFIELDS, _impl->_initDataString.c_str() );
//      }
//      
//      // Create an endpoint using the URL, then create the connection
//      endpoint = nw_endpoint_create_url( _impl->_url.c_str() );
//      params = nw_parameters_create_secure_tcp(NW_PARAMETERS_DEFAULT_CONFIGURATION,
//         NW_PARAMETERS_DEFAULT_CONFIGURATION );
//      _impl->_connection = nw_connection_create( endpoint, params );
//      if ( !_impl->_connection )
//      {
//         std::stringstream ss;
//         ss << "TODO: PUT ERROR HERE. Docs say 'Fails due to invalid parameters'";
//         throw propsyncError(ss.str());
//      }
//
//      // Set a worker queue
//      //auto queue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0);
//      auto queue = dispatch_queue_create("HTTP Download", DISPATCH_QUEUE_SERIAL);
//      if ( !queue )
//         throw propsyncError("Could not access global dispatch queue");
//      nw_connection_set_queue( _impl->_connection, queue );
//
//      // Monitor connection state changes, update our synchronization variable and error
//      std::mutex m;
//      std::unique_lock<std::mutex> ul(m);
//      std::condition_variable syncLock;
//      std::unique_ptr<propsyncError> error = nullptr;
//      auto continueWithError = [&syncLock, &error](std::string errorStr = "") {
//         if ( errorStr != "" )
//            error = std::make_unique<propsyncError>( errorStr );
//         syncLock.notify_one();
//      };
//      nw_connection_set_state_changed_handler(_impl->_connection, ^(nw_connection_state_t state, nw_error_t e) {
//         switch (state) {
//            case nw_connection_state_waiting:
//               std::cout << "waiting" << std::endl; break;
//            case nw_connection_state_failed: continueWithError("Connection failed"); break;
//            case nw_connection_state_ready: continueWithError(); break;
//            case nw_connection_state_cancelled:
//               std::cout << "connection is cancelled" << std::endl; break;
//            default: break;
//         }
//      });
//
//      // Start the connection
//      nw_connection_start( _impl->_connection );
//      syncLock.wait( ul );
//      if ( error ) throw *error;
//
//      // Be ready to receive before sending the HTTP request
//      _impl->receive([continueWithError](bool success) {
//         continueWithError();
//      });
//
//      // Send our request
//      NSString * nsRequest = [NSString stringWithCString: request.str().c_str() encoding:[NSString defaultCStringEncoding]];
//      NSData * rawData = [nsRequest dataUsingEncoding:NSUTF8StringEncoding];
//      dispatch_data_t dispatch_data = dispatch_data_create([rawData bytes], [rawData length], dispatch_get_main_queue(), DISPATCH_DATA_DESTRUCTOR_DEFAULT);
//      nw_connection_send(_impl->_connection,
//         dispatch_data,
//         NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT,
//         true,
//         ^(nw_error_t  _Nullable error) {
//            if (error != NULL)
//               continueWithError("Send HTTP/S request failed");
//            // Nothing more to do here, continuation will happen in our receive() completion callback
//         }
//      );
//      auto cvs = syncLock.wait_for( ul, _impl->_config->at("timeout").value<int>() * 1s );
//      if ( error ) throw *error;
//      else if ( cvs == std::cv_status::timeout ) throw propsyncError( "HTTP timeout" );
//
//      // TODO: Move this to close()
//      nw_connection_cancel(_impl->_connection);

// -----------------------------------------------
         
//      CURLcode res = curl_easy_perform( _impl->_curlHandle );
//      if ( res != CURLE_OK )
//      {
//         std::stringstream ss;
//         ss << "HTTP download failed with cURL error " << res << ": " << curl_easy_strerror( res );
//         throw propsyncError(API_TYPE_NAME( BAD_URL ), ss.str());
//      }



      // Force a NULL terminator
      _impl->_buffer.push_back( 0 );

      // Convert the data to propsync
      if ( _impl->_domParsing )
         _impl->_bytesRead = _impl->_serializer->deserialize( _impl->_buffer.data(), _impl->_buffer.size(), tempProps, UPSERT_POLICY::KEEP_NEW, parseOrder );
      else
         _impl->_bytesRead = _impl->_serializer->deserialize( _impl->_buffer.data(), _impl->_buffer.size(), _impl->_propProvider->get() );

      // Handle the delayed behavior of emulated DOM parsing, even though we always use SAX parsing internally
      if ( _impl->_domParsing )
      {
         // Move the now-completed temp props to the real prop provider.
         // We are not replacing the original root, just modifying it.
         // TODO: For legacy support, trigger the rootChanging and rootChanged callbacks. This may be deprecated in the future
         auto eventId = std::hash<property>{}(_impl->_propProvider->get().root());
         _impl->_propProvider->get().rootChanging.invoke( rootChangeEventModel( eventId, &_impl->_propProvider->get(), &_impl->_propProvider->get(), std::ref(_impl->_propProvider->get().root())) );
         if ( _impl->_propProvider->get().root().key() != tempProps.root().key() )
            _impl->_propProvider->get().root().key( tempProps.root().key() );
         _impl->_propProvider->get().rootChanged.invoke( rootChangeEventModel( eventId, &_impl->_propProvider->get(), &_impl->_propProvider->get(), std::ref(_impl->_propProvider->get().root())) );
         _impl->_propProvider->get().root().upsert( tempProps.extractRoot(), UPSERT_POLICY::MERGE_KEEP_NEW, false );
         _impl->_propProvider->get().root().triggerAllEvents( parseOrder );
      }

      failed = false;
      synced.invoke();

      return *this;
   }
   void httpSynchronizer::close()
   {
      // Supposedly ARC will do the right thing here in terms of releasing
      _impl->session = nullptr;
   }
   bool httpSynchronizer::isOpen() const
   {
      return _impl->_isOpen;
   }
   bool httpSynchronizer::isOpening() const
   {
      return _impl->_isOpening;
   }
   void httpSynchronizer::propProvider( std::optional< std::reference_wrapper< class propProvider > > propProvider )
   {
      _impl->_propProvider = propProvider;
   }
   size_t httpSynchronizer::numConnections() const
   {
      return 0;
   }
   size_t httpSynchronizer::numBytesRead() const
   {
      return _impl->_bytesRead;
   }
   size_t httpSynchronizer::numBytesWritten() const
   {
      return _impl->_bytesWritten;
   }

//   void httpSynchronizer::PIMPL::receive( receiveDelegate completionCallback )
//   {
//      // Recursively receive the data asynchronously, stopping only when the data is complete.
//      // Once complete, make the completion callback.
//      nw_connection_receive( _connection,
//         MIN_LENGTH,
//         MAX_LENGTH,
//         ^(_Nullable dispatch_data_t content, _Nullable nw_content_context_t context, bool is_complete, _Nullable nw_error_t error) {
//            const size_t dataSize = ((NSData *)content).length;
//            const uint8_t * bytes = static_cast<const uint8_t *>(((NSData *)content).bytes);
//            std::copy( bytes, bytes + dataSize, std::back_inserter(this->_buffer) );
//
//            if ( is_complete )
//               completionCallback(is_complete);
//            else
//               this->receive( completionCallback );
//         }
//      );
//   }
}
#endif



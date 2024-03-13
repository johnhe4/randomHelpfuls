#include <Foundation/Foundation.h>
#include <Security/Security.h>
#include <propsync/cpp/property.hpp>
#include <propsync/cpp/propsyncError.hpp>
#include "appleCertificate.h"

namespace ps
{
   void getCert()
   {
//static const UInt8 kKeychainItemIdentifier[] = "com.apple.dts.KeychainUI\0";
static const UInt8 kKeychainItemIdentifier[] = "com.apple.systemdefault\0";
NSData * keychainItemID = [NSData dataWithBytes:kKeychainItemIdentifier length:strlen((const char *)kKeychainItemIdentifier)];

      // Query certificates
      NSDictionary * query = @{ (id)kSecClass: (id)kSecClassCertificate, // We want certificates from the keychain
         (id)kSecMatchLimit: (id)kSecMatchLimitAll, // No limit
         (id)kSecAttrGeneric: keychainItemID, // Optional. Used for filtering if you know of a specific certificate, remove to get all.
         (id)kSecUseDataProtectionKeychain: @YES, // Treat macos as if it is ios
         (id)kSecReturnRef: @YES }; // Return a reference to the certificate(s)
      CFTypeRef certs;
      OSStatus result = SecItemCopyMatching( (__bridge CFDictionaryRef)query, &certs );
      if ( result != noErr )
      {
         NSString * errorMsg = (__bridge NSString*)SecCopyErrorMessageString( result, NULL );
         if ( result == errSecMissingEntitlement )
         {
            // Help the user out - this error and associated message (A required entitlement isn't present) is not very helpful
            errorMsg = [errorMsg stringByAppendingString: @" This usually requires your application to set the 'keychain-access-groups' entitlement."];
         }
         throw propsyncError( [errorMsg UTF8String] );
      }

      // Export certificates to an OpenSSL-friendly format
      CFDataRef exportedCerts;
      result = SecItemExport( certs,
         kSecFormatOpenSSL,
         0, // Can also force base-64 by using (id)kSecItemPemArmour
         NULL,
         &exportedCerts );

      // Copy the output to a C-buffer
      // TODO: implement

      // Release the references
      CFRelease( exportedCerts );
   }
}

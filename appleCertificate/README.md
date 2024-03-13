# Apple Certificates

Exports certificates from the keychain to something that can be consumed by OpenSSL.
I created this when trying to fix an issue with openssl on mobile devices,
but ended up not using it because the entitlements are difficult to configure on a shared library used in a console app.

The workaround I ended up using is BoringSSL. This is why this code is incomplete.

I cannot say exactly why boringssl works on android, macos, and ios, but it does. OpenSSL will build but fails at runtime
with an "SSL handshake" error.

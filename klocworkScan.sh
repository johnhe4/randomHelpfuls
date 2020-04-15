#!/bin/bash
#
############################################################
#
# Written by John Harrison, March 2020 (during COVID-19 lock-down)
# Assuming a CMAKE project(s) with a single root directory,
# this script attempts to run a standalone klocwork scan. 
# Even though it is standalone a license server is still needed
# for the thing to even start, so network connectivity is required.
#
# For reference, here is how I installed klocwork for standalone
# operation:
# 1. If your license server is behind a corporate network, then ensure
#    you are on said network (VPN should be okay)
# 2. Download Klocwork Client 2019.3. If using a browser, you'll need to
#    right-click and "Save-as" because it's a giant shell script, like ~500MB.
# 3. Make the script executable:
#      chmod +x kw-cmd-installer.linux64.sh
# 4. Make the installation directory writable (may not be needed
#    if you choose a different installation directory):
#      sudo chmod a+w /opt
# 5. Run in the installer, specifying the installation directory
#    that the installer will create:
#     ./kw-cmd-installer.linux64.sh --install-dir /opt/klocwork
# 6. To start a fresh scan from scratch, just delete the 'buildspec.out'
#    file inside the code directory, otherwise an incremental scan
#    will run. Note: any change to the license server requires a 
#    fresh scan!
#
############################################################

# You are expected to modify these
SCAN_TOOL=/opt/klocwork/bin/kwcheck
INJECT_TOOL=/opt/klocwork/bin/kwinject
CODE_ROOT=<path to your code>
LICENSE_HOST=<url to license server, such as klocwork02p.elic.company.com>
LICENSE_PORT=7500

# The rest is magic, shouldn't neet to touch.
ORIG_DIR=`pwd`
pushd $CODE_ROOT

# If we don't have a cmake cache file
if [ ! -f CMakeCache.txt ]; then

  # Use CMAKE to start fresh
  make clean
  rm CMakeCache.txt
  cmake .

fi

if [ ! -f buildspec.out ]; then

  rm -r .kw*
  $INJECT_TOOL -o buildspec.out make
  $SCAN_TOOL create -b buildspec.out --license-host $LICENSE_HOST --license-port $LICENSE_PORT

fi

# klockwork standalone madness
$SCAN_TOOL run
$SCAN_TOOL list -F detailed > $ORIG_DIR/report.txt

echo "Report written to 'report.txt'"

popd

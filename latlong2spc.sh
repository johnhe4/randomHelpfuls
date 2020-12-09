#!/bin/zsh
# John Harrison
# December, 2020
#
# References:
#  1. cs2cs man page
#  2. "PROJ coordinate transformation software library" documentation
#     https://raw.githubusercontent.com/OSGeo/PROJ/gh-pages/proj.pdf


# latitude and longitude coordinates
lat=30.205810928219
lon=-81.399408085859

# SPC "zone". Text form is similar to "NAD_1983_HARN_StatePlane_Florida_East_FIPS_0901_Feet"
# Up to 4 digits and do not include leading zeros
zone=901

# Convert and print the result
#  '-s' will reverse the output so N comes first, then W
#  '+units' specifies which units we are inputting
#  '-f <format>' Output ASCII-compatible lat/long (no degree symbols)
echo $lon $lat | cs2cs +proj=latlong +init=EPSG:4326 +to +init=NAD83:$zone +units=us-ft

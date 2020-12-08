#!/bin/zsh
# John Harrison
# December, 2020
#
# References:
#  1. cs2cs man page
#  2. "PROJ coordinate transformation software library" documentation
#     https://raw.githubusercontent.com/OSGeo/PROJ/gh-pages/proj.pdf


# X and Y coordinates
x=530000.5
y=2134998.0

# SPC "zone". Text form is similar to "NAD_1983_HARN_StatePlane_Florida_East_FIPS_0901_Feet"
# Up to 4 digits and do not include leading zeros
zone=901

# "false" easting and northing values. This isn't always needed
falseEasting=656166.66666666
falseNorthing=0

# Convert and print the result
#  '-s' will reverse the output so N comes first, then W
#  '+units' specifies which units we are inputting
#  '-f <format>' Output ASCII-compatible lat/long (no degree symbols)
echo $x $y | cs2cs +init=nad83:$zone +units=us-ft +x_0=$falseEasting +y_0=$falseNorthing +to -s -f "%.12f" +proj=latlong

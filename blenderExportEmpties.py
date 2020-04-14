import os
import sys
import math
import inspect
import bpy

if __name__ == "__main__":

   # Create our output .csv file
   file = open( "/Users/johnahar/code/ball.csv", "w+" )
   
   # Get the collection of interest
   collection = bpy.data.collections['ball']
   
   previousTimestamp = 99999999
   previousLocation = Vector()
   
   # Write all empties, using the empty name as the timestamp and first data column, followed by xyz of location
   for obj in collection.all_objects:
   
      if previousTimestamp > int(obj.name):
         previousTimestamp = int(obj.name)
      else:
         timestamp = int(obj.name)
         
         # Fill in frames as needed
         missingFrames = timestamp - previousTimestamp - 1
         locationDelta = obj.location - previousLocation
         for frameCounter in range(1, missingFrames+1):
            deltaPercentage = frameCounter / (missingFrames+1)
            interpolatedLocation = previousLocation + deltaPercentage*locationDelta
            file.write( str(previousTimestamp + frameCounter) + "," + str(interpolatedLocation[0]) + "," + str(interpolatedLocation[1]) + "," + str(interpolatedLocation[2]) + ",interpolated\n" )
            
         previousTimestamp = timestamp
         
      file.write( obj.name + "," + str(obj.location[0]) + "," + str(obj.location[1]) + "," + str(obj.location[2]) + "\n" )
      previousLocation = obj.location
   
   # Close the file
   file.close()

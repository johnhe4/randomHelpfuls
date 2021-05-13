import os
import math
import inspect
import bpy

def export(outputDir):

   transform = [1,-1,1]

   collection = bpy.data.collections['Collection']
   for object in collection.objects:
      filename = outputDir + "/" + object.name + ".csv"
      filename.replace(" ", "_" )
      file = open( filename, "w+" )
      vertices = [ object.matrix_world.to_3x3() @ vert.co for vert in object.data.vertices ]
      for vert in vertices:
         file.write( str(vert[0] * transform[0]) + "," + str(vert[1] * transform[1]) + "," + str(vert[2] * transform[2]) + "\n" )
      file.close()

if __name__ == "__main__":

   # In blender, you can run this script by:
   #    import sys
   #    sys.path.append("directory_containing_this_script")
   #    import blenderExportPoints
   #    blenderExportPoints.export("outputDirectory")
   export("./")

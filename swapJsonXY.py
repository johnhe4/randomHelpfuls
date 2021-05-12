import os
import math
import inspect
import sys
import json

def swapXY( inputJsonFilename, outputJsonFilename ):

   with open(inputJsonFilename, 'r') as inputFile:
      data = json.load(inputFile)
      for point in data['points']:
         x = point['X']
         point['X'] = point['Y']
         point['Y'] = x

      with open(outputJsonFilename, 'w') as outputFile:
         json.dump( data, outputFile )

if __name__ == "__main__":

   if len(sys.argv) < 2:
      print("Usage: swapJsonXY <inputJsonFilename> <outputJsonFilename>")
      exit()

   swapXY( sys.argv[1], sys.argv[2] )

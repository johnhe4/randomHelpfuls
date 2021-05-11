import os
import math
import inspect
import sys
import csv
import json

def csv2json( csvFilename, jsonFilename ):

   transform = [1,-1,1]

   with open( csvFilename, newline='' ) as csvFile:
      reader = csv.reader( csvFile )
      with open(jsonFilename, 'w') as jsonFile:
         data = {}
         data['points'] = []
         for row in reader:
            data['points'].append({
               'X': row[0],
               'Y': row[1],
               'Z': row[2]
            })
         json.dump( data, jsonFile )

if __name__ == "__main__":

   if len(sys.argv) < 2:
      print("Usage: pointsCsv2Json <csvFilename> <jsonFilename>")
      exit()

   csv2json( sys.argv[1], sys.argv[2] )

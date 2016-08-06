#!/usr/bin/python

from sys import argv

############################################################
# Read a TSV file and print the lat, lon values to stdout. #
# Andreas P. Koenzen                                       #
############################################################

# Arguments.
first = int(argv[1])

# Open the file.
fp = open("/Users/akc/Proyectos/GDSA/GDSA/Resources/Routes/Home-UCA-Route_1.tsv", "r")

for i, line in enumerate(fp):    
    if i == first:
        print line.rstrip('\n')

fp.close()

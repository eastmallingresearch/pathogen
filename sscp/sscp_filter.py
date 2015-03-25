#!/usr/bin/env python
import os
import sys

input_file = sys.argv[1]

f = open(input_file)
FileLines=[]
with open(input_file) as f:
	for line in f:
		FileLines.append(line.strip())
		
		
for line in FileLines:	
 	if line.startswith(">"):
 		header = line
 	else:
 		seq = line
		seq_len = len(seq)
  		if seq_len <= 150:
  			cys = (( seq.count('C') / float(seq_len) ) * 100)
  			if cys >= float(3):
  				header += "\t--cysteine%=\t"
  				header += str("{0:.0f}".format(cys))
  				print header, "\n", seq

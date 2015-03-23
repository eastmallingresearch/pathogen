#!/usr/bin/env python
import os
import sys

queryFile = sys.argv[1]
readsFile = sys.argv[2]

#open input file
#f = open(queryFile)
headerDic={}
with open(queryFile) as f:
	for line in f:
		line = line.strip()
#		print line.strip()
		headerline = "".join(("@", line))
#		print(headerline)
		headerDic[headerline] = 1
# M01678:6:000000000-A8H45:1:1101:16574:1238
#@M01678:4:000000000-A8H52:1:1101:16307:1025
		
#f = open(readsFile)
fileLines=[]
with open(readsFile) as f:
	for line in f:
		fileLines.append(line.strip())
				
#for header, seq in fileLines[:2]:
printnext = 0
for line in fileLines:
#	print(line) 
 	if line.startswith('@M01678'):		
 		if "".join(line.split()[0]) in headerDic:
 			print(line)
 			printnext = 3
# 		print("".join(line.split()[0]))
#  		printnext = 3
   	elif printnext > 0:
  		print(line)
  		printnext -= 1



#!/usr/bin/env python
import os
import sys

'''
Script to extract sequencing reads from a fastq file which match headers from another file.
fastq_filter.py <Query_IDs.txt> <sequencing_reads.fastq> > outfile.fastq
'''

queryFile = sys.argv[1]
readsFile = sys.argv[2]

#------------------------------------------------
#	open input files
#------------------------------------------------
# Store query headers in a dictionary where they 
# can be quickly accessed.
# Read fastq files into memory.

headerDic={}
with open(queryFile) as f:
	for line in f:
		line = line.strip()
		headerline = "".join(("@", line))
		headerDic[headerline] = 1

fileLines=[]
with open(readsFile) as f:
	for line in f:
		fileLines.append(line.strip())


#------------------------------------------------
#	Print fastq accessions 
#------------------------------------------------
# a) Print if header is present in in the dictionary
# b) Print the following three lines.
				
printnext = 0
for line in fileLines:
 	if line.startswith(('@M01678', '@HWUSI')):		
 		if "".join(line.split()[0]) in headerDic:
 			print(line)
 			printnext = 3
   	elif printnext > 0:
  		print(line)
  		printnext -= 1



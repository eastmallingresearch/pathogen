#!/usr/bin/env python
import os
import sys
header_dict = {}
test_dict = {}

def build_header_dict(header_infile):
	with open (header_infile, 'r') as header_fh:
		for cur_line in header_fh:
			header_dict[cur_line.strip()] = 'seen'
		return header_dict
		
def test_dict(fastq_infile, header_dict):
	remaining_printlines = 0
	with open (fastq_infile, 'r') as fastq_fh:
		for cur_line in fastq_fh:
			if ('@M00712' in cur_line
				and cur_line.partition(' ')[0] in header_dict):
				remaining_printlines = 3
				print cur_line.strip()
			elif remaining_printlines > 0:
				print cur_line.strip()
				remaining_printlines -= 1
				
header_infile = sys.argv[1]
f_read_infile = sys.argv[2]
header_dict = build_header_dict(header_infile)
test_dict(f_read_infile, header_dict)

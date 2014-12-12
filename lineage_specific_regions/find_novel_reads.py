#!/usr/bin/env python
import os
import sys
header_dict = {}
test_dict = {}
usage = "find_novel_reads.py <list_of_reads.txt> <file_of_reads.fa/fq> [-fq/-fa]"

def build_header_dict(header_infile):
	with open (header_infile, 'r') as header_fh:
		for cur_line in header_fh:
			header_dict[cur_line.strip()] = 'seen'
		return header_dict
		
def fq_test_dict(fastq_infile, header_dict):
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
				
def fa_test_dict(fasta_infile, header_dict):
	remaining_printlines = 0
	with open (fasta_infile, 'r') as fasta_fh:
		for cur_line in fasta_fh:
			if ('>' in cur_line
				and cur_line[1:].strip() in header_dict):
				remaining_printlines = 1
				print cur_line.strip()
			elif remaining_printlines > 0:
				print cur_line.strip()
				remaining_printlines -= 1
				
header_infile = sys.argv[1]
f_read_infile = sys.argv[2]
fasta_type = sys.argv[3]
header_dict = build_header_dict(header_infile)
if fasta_type == '-fq':
	fq_test_dict(f_read_infile, header_dict)
elif fasta_type == '-fa':
	fa_test_dict(f_read_infile, header_dict)
else:
	print "Error\n:" + usage

#!/usr/bin/python

'''
Parse the headers of a genomic fasta file for blastz (part of tba). The
'''

import sys,argparse
import re
# from Bio import SeqIO
# from BCBio import GFF
from collections import defaultdict

ap = argparse.ArgumentParser()
ap.add_argument('--inp_fasta',required=True,type=str,help='input FASTA file')
ap.add_argument('--new_headers',required=True,type=str,help='Fasta header file provided by the tba program get_standard_headers.')
conf = ap.parse_args()
firstline = True
seqline = []

with open(conf.new_headers) as f:
    h_lines = f.readlines()

with open(conf.inp_fasta) as f:
    f_lines = f.readlines()

header_dict = defaultdict(list)
header = ''
for line in h_lines:
    line = line.rstrip()
    if line.startswith('>'):
        header = line
        header = re.sub(' ==>$', '', header)
        # print(header)
    else:
        extension = line
        header_dict[header].append(extension)

for line in f_lines:
    line = line.rstrip()
    if line.startswith('>'):
        header = line
        extension = "".join(header_dict[header])
        new_header = header + ":" + extension
        line = new_header
    print (line)

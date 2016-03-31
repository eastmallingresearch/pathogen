#!/usr/bin/python

'''
This tool is intended for extraction of DNA sequence between given co-ordinates.
A file containing the location of blast hits against the genome is supplied.
BLast co-ordinates are extracted from the file through specifying on the command
line which columns contain contig name, blast hit start, stop and strand.
'''


#-----------------------------------------------------
# Step 1
# Import variables & load input files
#-----------------------------------------------------

import sys
import argparse
import re
from sets import Set
from collections import defaultdict
from operator import itemgetter

import Bio
from Bio import Seq
from Bio import SeqIO

ap = argparse.ArgumentParser()
ap.add_argument('--coordinates_file',required=True,type=str,help='A file containing locations of features that will be extracted')
ap.add_argument('--header_column',required=True,type=int,help='The column number containing fasta headers')
ap.add_argument('--start_column',required=True,type=int,help='The column number containing start co-ordinates')
ap.add_argument('--stop_column',required=True,type=int,help='The column number containing stop co-ordinates')
ap.add_argument('--strand_column',required=True,type=int,help='The column number containing which orientation the feature should be extracted in')
ap.add_argument('--id_column',required=True,type=int,help='The column number containing the name for this feature')
ap.add_argument('--fasta_file',required=True,type=str,help='The fasta file from which sequences will be extracted.')
conf = ap.parse_args()


with open(conf.coordinates_file) as f:
    coordinates_lines = f.readlines()

# with open(conf.fasta_file) as f:
#     fasta_lines = f.readlines()

header_col=(conf.header_column -1)
start_col=(conf.start_column -1)
stop_col=(conf.stop_column -1)
strand_col=(conf.strand_column -1)
id_col=(conf.id_column -1)


#-----------------------------------------------------
# Step 2
# Build a dictionary of coordinates for extraction
#-----------------------------------------------------

coordinates_dict = defaultdict(list)
for line in coordinates_lines:
    line = line.rstrip()
    split_line = line.split("\t")
    l = len(split_line)
    # print l
    # print (", ".join([str(header_col), str(start_col), str(stop_col), str(strand_col), str(id_col)]))
    if header_col > l or start_col > l or stop_col > l or strand_col > l or id_col > l:
        continue
    column_list=itemgetter(header_col, start_col, stop_col, strand_col, id_col)(split_line)
    header=column_list[0]
    # print(",".join(column_list))
    coordinates_dict[header].append("\t".join(column_list))


#-----------------------------------------------------
# Step 3
# Itterate through the fasta accessions, extracting
# sequence data
#-----------------------------------------------------

seq_records = list(SeqIO.parse(conf.fasta_file, "fasta"))
# print(len(seq_records))

for accession in seq_records:
    header = accession.id
    # print header
    for coordinates in coordinates_dict[header]:
        # print ("hello")
        # print coordinates
        coordinate_list = coordinates.split("\t")
        # print coordinate_list
        start = int(coordinate_list[1])
        stop = int(coordinate_list[2])
        extracted_seq = accession.seq[start:stop]
        if '-' in coordinate_list[3]:
            # print ("reversed")
            extracted_seq = Seq.reverse_complement(extracted_seq)
        print (">" + coordinate_list[4])
        print extracted_seq
    # print accession.id
    # print accession.seq[5:10]

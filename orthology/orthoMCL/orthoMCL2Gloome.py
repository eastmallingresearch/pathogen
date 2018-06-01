#!/usr/bin/python

'''
This tool uses an orthology group txt file output from OrthoMCl to extract
fasta accessions from a goodProteins.fa file.
'''

from sets import Set
import sys,argparse
from collections import defaultdict
import re

#----------------------------------------------
# Step 1
# Import variables & load input files
#-----------------------------------------------------

ap = argparse.ArgumentParser()
ap.add_argument('--orthogroups',required=True,type=str,help='text file output of OrthoMCl orthogroups')
ap.add_argument('--isolate_list',required=True,type=str,nargs='+',help='the fasta file of proteins used for the orthology analysis.')
ap.add_argument('--true_names',required=True,type=str,nargs='+',help='the fasta file of proteins used for the orthology analysis.')
ap.add_argument('--missing_isolates',required=True,type=str,nargs='+',help='the fasta file of proteins used for the orthology analysis.')
conf = ap.parse_args()

with open(conf.orthogroups) as f:
    orthogroup_lines = f.readlines()

isolate_list = conf.isolate_list
truenames_list = conf.true_names
missing_list = conf.missing_isolates

#----------------------------------------------
# Step 1
# Import variables & load input files
#-----------------------------------------------------

fasta_dict = defaultdict(str)

for line in orthogroup_lines:
    line = line.rstrip("\n")
    split_line = line.split(" ")
    orthogroup_id = split_line[0].replace(":", "")
    for isolate in isolate_list:
        if isolate + "|" in line:
            fasta_dict[isolate] += '1'
        else:
            fasta_dict[isolate] += '0'

for orthomclID, trueID in zip(isolate_list, truenames_list):
    print("".join(['>' + trueID]))
    print(fasta_dict[orthomclID])

for trueID in missing_list:
        print("".join(['>' + trueID]))
        another_isolate_str = fasta_dict[isolate_list[0]]
        # missing_values_str = re.sub(r"0|1", '-', another_isolate_str,)
        missing_values_str = re.sub(r"0|1", '1', another_isolate_str,)
        print(missing_values_str)

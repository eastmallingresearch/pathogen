#!/usr/bin/python

'''
This tool converts a set of orthology relationships predicted by tribemcl into
a matrix showing orthogroups posessed by isolates. This matrix can be used to
plot venn diagrams of shared ortholog groups between genomes.
'''

from sets import Set
import sys,argparse
from collections import defaultdict
import re


#-----------------------------------------------------
# Step 1
# Import variables & load input files
#-----------------------------------------------------

ap = argparse.ArgumentParser()
ap.add_argument('--orthogroups',required=True,type=str,help='text file output of OrthoMCl orthogroups')
# ap.add_argument('--out_dir',required=True,type=str,help='the directory where fasta files containing orthogroups will be written ')
conf = ap.parse_args()

with open(conf.orthogroups) as f:
    # ortho_lines = f.readlines()
    ortho_lines = (line.rstrip() for line in f)
    ortho_lines = list(ortho_lines for ortho_lines in ortho_lines if ortho_lines) # Non-blank lines in a list

#-----------------------------------------------------
# Step 2
# Build a dictionary of orthogroups
#-----------------------------------------------------

ortho_dict = defaultdict(list)
# ortho_dict = {}
for line in ortho_lines:
    line = line.rstrip().rstrip()
    if line.startswith('%'):
        print ("spoons")
        continue
    # split_line = ''
    split_line = line.split()
    # print ("monkeys")
    # for element in split_line:
        # print (element),
    # print("")
    # print(split_line)
    gene = split_line[0]
    orthogroup = split_line[1]
    # print (gene + " - " + orthogroup)
    # ortho_dict[str(orthogroup)].append(gene)
# exit

#-----------------------------------------------------
# Step 3
# Parse the dictionary into a matrix
#-----------------------------------------------------

print (ortho_dict)

# keys = []
# sorted_keys = []
# keys = ortho_dict.keys()
#
# keys.sort(key=int)
# header_line = []
# ortho_list = []
# for group_name in keys:
#     Organism_dict["header_line"].append("orthogroup" + str(group_name))
#     ortho_list = ortho_dict[group_name]
#     for Organism in Organism_list:
#         if Organism in ortho_list:
#             Organism_dict[Organism].append("1")
#         else:
#              Organism_dict[Organism].append("0")
#
#
#
#     outfile = str(conf.out_dir) + "/orthogroup" + str(group_name) + ".fa"
#     with open(outfile, 'w') as o:
#         for line in ortho_fasta:
#             o.write(line + "\n")

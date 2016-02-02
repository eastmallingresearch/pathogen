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
ap.add_argument('--orthogroups',required=True,type=str,help='The text file containing the tribMCL ortholog groups')
ap.add_argument('--out_txt',required=True,type=str,help='Output file containing the ortholog groups in orthoMCL output format')
ap.add_argument('--out_tab',required=True,type=str,help='Output file containing the matrix of ortholog groups used to construct a venn diagram.')
conf = ap.parse_args()

with open(conf.orthogroups) as f:
    ortho_lines = (line.rstrip() for line in f)
    ortho_lines = list(ortho_lines for ortho_lines in ortho_lines if ortho_lines) # For all non-blank lines in a list

#-----------------------------------------------------
# Step 2
# Build a dictionary of orthogroups
#-----------------------------------------------------

split_organsim = []
organism_set = Set([])
ortho_dict = defaultdict(list)

print ("Reading infile")
for line in ortho_lines:
    line = line.rstrip().rstrip()
    if line.startswith('%'):
        print(line)
        continue
    split_line = line.split()
    gene = split_line[0]
    orthogroup = split_line[1]
    split_organism = gene.split("|")
    organism_set.add(split_organism[0])
    ortho_dict[str(orthogroup)].append(gene)

#-----------------------------------------------------
# Step 3
# Parse the dictionary into a matrix
#-----------------------------------------------------

keys = []
sorted_keys = []
keys = ortho_dict.keys()
out_txt_lines = []
organism_dict = defaultdict(list)

keys.sort(key=int)
header_line = []
ortho_list = []
print("The organisms contained in this dataset are:\t" + " ".join(organism_set))
for group_name in keys:
    # Prepare output lines parsed into orthomcl format
    ortho_list = ortho_dict[group_name]
    out_txt_lines.append("orthogroup" + group_name + ": " + " ".join(ortho_list))
    # Prepare a matrix for venn diagram plotting
    organism_dict["header_line"].append("\"orthogroup" + str(group_name) + '\"')
    for organism in organism_set:
        if any(organism in s for s in ortho_list):
            organism_dict[organism].append("1")
        else:
            organism_dict[organism].append("0")


#-----------------------------------------------------
# Step 4
# Print output lines
#-----------------------------------------------------

# Output the proteins contained in each orthogroup in orthoMCL format
with open(conf.out_txt, 'w') as o:
    for line in out_txt_lines:
        o.write (line + "\n")
# Output the matrix of orthogroups for plotting of a venn diagram
with open(conf.out_tab, 'w') as o:
    o.write ( "" + "\t" + "\t".join(organism_dict["header_line"]) + "\n")
    for organism in organism_set:
        o.write ('\"' + organism + "\"\t" + "\t".join(organism_dict[organism]) + "\n")

exit

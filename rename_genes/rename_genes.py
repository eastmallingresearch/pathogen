#!/usr/bin/python

'''
Genes may have been renamed during the genbank submission process.
This script can be used to rename genes in final tables.
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

ap = argparse.ArgumentParser()

ap.add_argument('--new_names',required=True,type=str,help='A tab seperated file showing relation of old and new gene names')
ap.add_argument('--input_table',required=True,type=str,help='A tab-seperated file containing the old gene names that need to be replaced')
ap.add_argument('--ignore_header',required=False,type=bool, help='Ignore the first line as it contains headers.')
ap.add_argument('--id_column',required=True,type=int,help='geneIDs are contained in column')

conf = ap.parse_args()

with open(conf.new_names) as f:
    name_lines = f.readlines()
with open(conf.input_table) as f:
    table_lines = f.readlines()

header = False
if conf.ignore_header:
    header = conf.ignore_header

ID_col = (conf.id_column) -1

#--------------------------------------------------
# Step 2
#
#-----------------------------------------------------

gene_id_dict = defaultdict(list)
for line in name_lines:
    line = line.rstrip()
    if line.startswith("old_id"):
        continue
    split_line = line.split()
    old_id = split_line[0]
    new_id = split_line[1]
    # Remove locus-tag prefix from geneIDs
    old_id = old_id[6:]
    gene_id_dict[old_id].append(new_id)

#--------------------------------------------------
# Step 3
#
#-----------------------------------------------------

First = True
for line in table_lines:
    line = line.rstrip()
    if header == True and First == True:
        First = False
        print line
        continue
    split_line = line.split()
    gene_col = split_line[ID_col]
    # print gene_col
    old_id = gene_col.split(".")[0]
    # print old_id
    new_id = "".join(gene_id_dict[old_id])
    # print new_id
    line = re.sub(old_id, new_id, line)
    print line

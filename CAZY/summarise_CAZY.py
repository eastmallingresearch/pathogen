#!/usr/bin/python

'''
This Script is intended to summarise the results of CAZY, giving information on
which proteins contain a signal peptide and giving breakdowns of the numbers of
CAZY genes by family and by contig.
'''

import sys
import argparse
import re
from sets import Set
from collections import defaultdict
from collections import Counter
from operator import itemgetter


#-----------------------------------------------------
# Step 1
# Import variables & load input files
#-----------------------------------------------------

ap = argparse.ArgumentParser()
ap.add_argument('--cazy',required=True,type=str,help='input CAZY file')
ap.add_argument('--inp_secreted',required=True,type=str,help='List of secreted genes')
ap.add_argument('--inp_gff',required=True,type=str,help='gene annotations to provide a breakdown by contig')
ap.add_argument('--summarise_family',required=False,default=False, action='store_true',help='Summarise CAZY gene models by CAZY functional family')
# ap.add_argument('--out_secreted',required=True,type=str,help='headers of secreted CAZY genes')
# ap.add_argument('--out_by_contig',required=True,type=str,help='breakdown of secreted CAZY gene families by contig')

conf = ap.parse_args() #sys.argv

with open(conf.cazy) as f:
    inp_lines = f.readlines()

with open(conf.inp_secreted) as f:
    secreted_lines = f.readlines()

with open(conf.inp_gff) as f:
    gff_lines = f.readlines()

summarise_family = conf.summarise_family

#-----------------------------------------------------
# Step 2
# Create a set of secreted genes
#-----------------------------------------------------

secreted_set = Set([])
for line in secreted_lines:
    line = line.rstrip()
    split_line = line.split()
    gene_id = split_line[0].replace(">", "")
    secreted_set.add(gene_id)

# print secreted_set


#-----------------------------------------------------
# Step 3
# Process CAZY file
#-----------------------------------------------------

seen_set = Set([])
family_set = Set([])
gene_dict = defaultdict(list)
family_dict = defaultdict(list)
for line in inp_lines:
    line = line.rstrip()
    split_line = line.split()
    family = split_line[0]
    if summarise_family == True:
        family = family[0:2]
        family = family.replace("CB", "CBM")
    gene_id = split_line[2]
    # print gene_id
    if gene_id in secreted_set and gene_id not in seen_set:
        seen_set.add(gene_id)
        family_set.add(family)
        gene_dict[gene_id].append(family)
        family_dict[family].append(gene_id)

for family in family_dict.keys():
    family_sz = len(family_dict[family])
    # print " - ".join([str(family), str(family_sz)])

#-----------------------------------------------------
# Step 4
# By contig
#-----------------------------------------------------

gene_count_dict = defaultdict(int)
contig_dict = defaultdict(list)

for line in gff_lines:
    line = line.rstrip()
    split_line = line.split()
    if split_line[2] == "mRNA":
        col9 = split_line[8]
        col9_split = col9.split(";")
        gene_id = col9_split[0]
        gene_id = gene_id.replace("ID=", "")
        contig = split_line[0]
        gene_count_dict[contig] += 1
        if gene_id in seen_set:
            # family = family_dict[gene_id]
            family = ";".join(gene_dict[gene_id])
            # print family
            # print gene_id
            contig_dict[contig].append(family)

keys = contig_dict.keys()
for contig in sorted(keys):
    family_list = contig_dict[contig]
    num_CAZY_genes = len(family_list)
    gene_count = gene_count_dict[contig]
    print " - ".join([str(contig), str(num_CAZY_genes), str(gene_count)])
    # print family_list
    genes_by_family = Counter(family_list)
    # print genes_by_family
    for family in family_set:
        print "\t".join([family, str(genes_by_family[family])])

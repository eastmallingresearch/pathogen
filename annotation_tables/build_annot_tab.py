#!/usr/bin/python

'''
This program is used to build information on all the genes predicted in
an annotated genome. These commands take information on location of genes
& suppliment this information with information on interproscan domains
and swissprot annotations.
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

ap.add_argument('--genome',required=True,type=str,help='A fasta file of the assembled contigs')
ap.add_argument('--FoC_genes_gff',required=True,type=str,help='A gff file of the genes from the FoC')
ap.add_argument('--InterPro',required=True,type=str,help='The Interproscan functional annotation .tsv file')
ap.add_argument('--Swissprot',required=True,type=str,help='A parsed table of BLAST results against the Swissprot database. Note - must have been parsed with swissprot_parser.py')

conf = ap.parse_args()


with open(conf.genome) as f:
    contig_lines = f.readlines()

with open(conf.FoC_genes_gff) as f:
    FoC_genes_lines = f.readlines()


with open(conf.InterPro) as f:
    InterPro_lines = f.readlines()

with open(conf.Swissprot) as f:
    swissprot_lines = f.readlines()

column_list=[]


#-----------------------------------------------------
# Step 2
# Collect information on contig length from the genome
# assembly file. This can be used to determine if a
# gene has 2kb of sequence assembled up and downstream.
# This important for knock out design.
#-----------------------------------------------------

gene_id_set = Set([])
contig_len_dict = defaultdict(list)
contig_id = ""
seq_lines = ""
for line in contig_lines:
    line = line.rstrip()
    if line.startswith(">"):
        last_seq_length = len(seq_lines)
        contig_len_dict[contig_id] = len(seq_lines)
        split_line = line.split(" ")
        contig_id = split_line[0].replace(">", "")
        seq_lines = ""
    else:
        seq_lines += line

#-----------------------------------------------------
# Step 4
# Append co-ordinates from the FoC gene gff, showing
# gene locations.
# Also identify whether there is 2kb sequence data up
# and downstream of the gene allowing design of
# knockouts
#-----------------------------------------------------

gene_id_set = Set([])
FoC_genes_dict = defaultdict(list)
for line in FoC_genes_lines:
    if "gff-version" in line:
        continue
    if line.startswith('#'):
        continue
    line = line.rstrip()
    split_line = line.split("\t")
    if 'mRNA' in split_line[2]:
        gene_features = split_line[8].split(';')
        gene_id = gene_features[0]
        gene_id = gene_id.replace('ID=', '')
        column_list = ["", "", "", ""]
        gene_id_set.add(gene_id)
        column_list=itemgetter(0, 3, 4, 6)(split_line)
        for column in column_list:
            FoC_genes_dict[gene_id].append(column)

        contig_id = column_list[0]
        feature_start=int(column_list[1])
        feature_end=int(column_list[2])
        contig_length = contig_len_dict[contig_id]
        if (feature_start - 2000) > 0 and (feature_end +2000) < contig_length:
            FoC_genes_dict[gene_id].append("Flank")
        else:
            FoC_genes_dict[gene_id].append("")



#-----------------------------------------------------
# Step 12
# Build a dictionary of interproscan annotations
# Annotations first need to be filtered to remove
# redundancy. This is done by first loading anntoations
# into a set.
#-----------------------------------------------------

interpro_set =  Set([])
interpro_dict = defaultdict(list)

for line in InterPro_lines:
    line = line.rstrip("\n")
    split_line = line.split("\t")
    interpro_columns = []
    index_list = [0, 4, 5, 11, 12]
    for x in index_list:
        if len(split_line) > x:
            interpro_columns.append(split_line[x])
    set_line = ";".join(interpro_columns)
    if set_line not in interpro_set:
        gene_id = interpro_columns[0]
        interpro_feat = ";".join(interpro_columns[1:])
        interpro_dict[gene_id].append(interpro_feat)
    interpro_set.add(set_line)


#-----------------------------------------------------
# Step 13
# Build a dictionary of Swissprot annotations
#-----------------------------------------------------

swissprot_dict = defaultdict(list)

for line in swissprot_lines:
    line = line.rstrip("\n")
    split_line = line.split("\t")
    gene_id = split_line[0]
    swissprot_columns = itemgetter(14, 12, 13)(split_line)

    swissprot_dict[gene_id].extend(swissprot_columns)


#-----------------------------------------------------
# Step 12
# Print final table of information on query, blast
# results and genes intersecting blast results
#-----------------------------------------------------

print ("\t".join([
"query_id", "contig", "gene_start", "gene_end", "gene_strand",
"2kb_flank",
"Swissprot_organism", "Swissprot_hit", "Swissprot_function",
"Interpro_annotations"
]))

for gene_id in gene_id_set:
    useful_columns=[gene_id]
    useful_columns.extend(FoC_genes_dict[gene_id])
    if swissprot_dict[gene_id]:
        useful_columns.extend(swissprot_dict[gene_id])
    else:
        useful_columns.extend(["","",""])

    if interpro_dict[gene_id]:
        interpro_col = "|".join(interpro_dict[gene_id])
        useful_columns.append(interpro_col)
    else:
        useful_columns.append("")

    print ("\t".join(useful_columns))

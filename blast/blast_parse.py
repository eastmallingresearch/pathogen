#!/usr/bin/python

'''
This summarises results from blast2csv from multiple files, building a matrix
of blast hits for each genome searched against. Percentage identify accross the
blast hit and e-value of the hit need to be over a given threshold.
'''


#-----------------------------------------------------
# Step 1
# Import variables & load input files
#-----------------------------------------------------

import sys
import argparse
import re
import numpy as np
from sets import Set
from collections import defaultdict
from operator import itemgetter

ap = argparse.ArgumentParser()
ap.add_argument('--blast_csv',required=True,nargs='+',type=str,help='Blast2csv output')
ap.add_argument('--headers',required=True,nargs='+',type=str,help='names of target genomes for use as headers in the outpit file. Order must be the same as the Blast2csv output')
ap.add_argument('--identity',required=True,type=float,help='Threshold of percentage identity accross the entire query length')
ap.add_argument('--evalue',required=True,type=float,help='Threshold of E-value for any blast hit')
conf = ap.parse_args()

csv_files = conf.blast_csv
headers = conf.headers
thresh_perc_id = conf.identity
thresh_eval = conf.evalue

# print len(headers)
# print len(csv_files)
if len(headers) != len(csv_files):
    raise ValueError('different number of header names from blast_csv files')

hits_dict = defaultdict(list)

num = 0
for csv_file in csv_files:
    num += 1
    # print num
    # header = csv_file.split("/")[-1].replace(".csv", "")
    gene_list = []
    with open(csv_file) as f:
        csv_lines = f.readlines()
    for line in csv_lines:
        line = line.rstrip()
        if line.startswith('ID'):
            headers_line = line
        else:
            split_line = line.split("\t")
            query_ID = split_line[0]
            query_seq = split_line[1]
            query_lgth = int(split_line[2])
            num_hits = int(split_line[3])
            over_threshold = 0
            gene_list.append(query_ID)
            if num_hits > 0:
                hits_cols = split_line[4:]
                for i in range(num_hits):
                    hit_contig = hits_cols.pop(0)
                    hit_eval = float(hits_cols.pop(0))
                    hit_lgth = int(hits_cols.pop(0))
                    hit_perc_lgth = float(hits_cols.pop(0))
                    hit_total_perc_id = float(hits_cols.pop(0))
                    hit_strand = hits_cols.pop(0)
                    hit_start = int(hits_cols.pop(0))
                    hit_end = int(hits_cols.pop(0))
                    hit_seq = hits_cols.pop(0)
                    perc_identity_accross_hit = np.divide(hit_total_perc_id, hit_perc_lgth)
                    if perc_identity_accross_hit >= thresh_perc_id and hit_eval <= thresh_eval:
                        over_threshold += 1
                        # print str(thresh_perc_id) + "\t" + str(hit_perc_id)
                        # print str(thresh_eval) + "\t" + str(hit_eval)
            hits_dict[query_ID].append(str(over_threshold))

# print num
outline = "Query ID's\t" + "\t".join(headers)
print outline
# outline = "Query ID's\t" + "\t".join(csv_files)
# print outline
for key in gene_list:
    outline = key + "\t" + "\t".join(hits_dict[key])
    print outline
    # print len(hits_dict[key])

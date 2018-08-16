#!/usr/bin/python

'''
This program is to select random DNA sequences of the same length and from
the same contigs as features passed to it from a gff file. This is used in
generating control sequences to test fungal transposons against in RIP
analysis. This is run individually for each transposon family of interest.
'''


#-----------------------------------------------------
# Step 1
# Import variables & load input files
#-----------------------------------------------------

import sys
import argparse
import re
import random
import numpy as np
from Bio.Seq import Seq
# from sets import Set
from collections import defaultdict
# from operator import itemgetter

ap = argparse.ArgumentParser()

ap.add_argument('--genome',required=True,type=str,help='Fasta file of the target genome')
ap.add_argument('--gff',required=True,type=str,help='A gff file of all transposon features in the target genome')
ap.add_argument('--alignment',required=True,type=str,help='Multiple alignment file of transposon features in fasta format. This is used to subset the gff file.')

conf = ap.parse_args()

with open(conf.genome) as f:
    contig_lines = f.readlines()
with open(conf.gff) as f:
    gff_lines = f.readlines()
with open(conf.alignment) as f:
    alignment_lines = f.readlines()

column_list=[]



#----------------------------------------------
# Step 2
#
#----------------------------------------------

contig_dict = defaultdict(str)
for line in contig_lines:
    line = line.rstrip()
    if line.startswith('>'):
        header = line.replace('>', '')
        # print header
    else:
        contig_dict[header] += line

# for header in contig_dict.keys():
#     print len(contig_dict[header])

#----------------------------------------------
# Step 2
#
#----------------------------------------------

for line in alignment_lines:
    line = line.rstrip()
    if line.startswith('>'):
        # print line
        header_split = line.split('_')
        contig_id = "_".join([header_split[1], header_split[2]])
        contig_start = header_split[3]
        contig_end = header_split[4]
        contig_orientation = header_split[5]
        # print ("\t").join([contig_id, contig_start, contig_end, contig_orientation])
        feature_length = int(contig_end) - int(contig_start)
        # print ("\t").join([contig_id, contig_start, str(feature_length)])
        contig_length = len(contig_dict[contig_id])
        # print contig_length
        # ratio_new = 0
        TA_count_new = 0
        AT_count_new = 0
        # Do this using a while loop in case the sample returns an unusable value:
        while TA_count_new == 0 and AT_count_new == 0:
            if contig_orientation == '+':
                new_start = random.randint(1,int(contig_length) - int(feature_length))
                new_end = new_start + int(feature_length)
                # print ("\t").join([contig_id, str(new_start), str(new_end)])
                new_seq = Seq(contig_dict[contig_id][new_start:new_end])
                # print new_seq
            if contig_orientation == '-':
                new_start = random.randint(1 + int(feature_length), int(contig_length))
                new_end = new_start + int(feature_length)
                # print ("\t").join([contig_id, str(new_start), str(new_end)])
                new_seq = Seq(contig_dict[contig_id][new_start:new_end]).reverse_complement()
                # print new_seq
            TA_count_new = len(re.findall('TA', str(new_seq)))
            AT_count_new = len(re.findall('AT', str(new_seq)))
            ratio_new = np.divide(float(TA_count_new), float(AT_count_new))
            ratio_new = np.round(ratio_new, 2)
        # print ("\t").join([str(TA_count_new), str(AT_count_new), str(ratio_new)])
        print ("\t").join(["control", str(TA_count_new), str(AT_count_new), str(ratio_new)])
    else:
        # print line
        seq = line.replace('-', '')
        # print seq
        TA_count_sample = len(re.findall('TA', str(seq)))
        AT_count_sample = len(re.findall('AT', str(seq)))
        ratio_sample = np.divide(float(TA_count_sample), float(AT_count_sample))
        ratio_sample = np.round(ratio_sample, 2)
        print ("\t").join(["sample", str(TA_count_sample), str(AT_count_sample), str(ratio_sample)])

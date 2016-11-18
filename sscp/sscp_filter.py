#!/usr/bin/env python
import os
import sys
from Bio import SeqIO
import sys,argparse

ap = argparse.ArgumentParser()
ap.add_argument('--inp_fasta',required=True,type=str,help='.fasta file containing query proteins')
ap.add_argument('--threshold',required=True,type=int,help='% threshold above which proteins are considered cysteine rich')
ap.add_argument('--out_fasta',required=True,type=str,help='output results .fasta file of all proteins')

conf = ap.parse_args()
out_records = []

for record in SeqIO.parse(conf.inp_fasta, "fasta"):
	seq = record.seq
	seq_len = len(record)
	cys = (( seq.count('C') / float(seq_len) ) * 100)
	record.description += "\t--cysteine%=\t"
	record.description += str("{0:.0f}".format(cys))
	if seq_len <= 150 and cys >= conf.threshold:
		record.description += "\t--SSCP=\tYes\t"
	else:
		record.description += "\t--SSCP=\tNo\t"
	out_records.append(record)

SeqIO.write(out_records, conf.out_fasta, "fasta")

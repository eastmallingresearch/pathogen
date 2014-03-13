#!/bin/bash
#Assemble contigs using velvet and generate summary statistics using process_contigs.pl
WORK_DIR=P.cact_assembly
HASH_LENGTH=45
FORWARD_FILE=P.cact_411_1M_F_trim.fastq
REVERSE_FILE=P.cact_411_1M_R_trim.fastq

velveth $WORK_DIR $HASH_LENGTH -fastq -shortPaired -separate $FORWARD_FILE $REVERSE_FILE
velvetg $WORK_DIR -long_mult_cutoff 1 -exp_cov 6 -ins_length 700 -cov_cutoff 2 -min_contig_lgth 750
process_contigs.pl -i $WORK_DIR/contigs.fa -o process_contigs_P.cact.1



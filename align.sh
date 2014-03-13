#!/bin/bash
velveth P.cact_assembly 45 -fastq -shortPaired -separate P.cact_411_1M_F_trim.fastq P.cact_411_1M_R_trim.fastq
velvetg P.cact_assembly -long_mult_cutoff 1 -exp_cov 6 -ins_length 700 -cov_cutoff 2 -min_contig_lgth 750
process_contigs.pl -i P.cact_assembly/contigs.fa -o process_contigs_P.cact.1



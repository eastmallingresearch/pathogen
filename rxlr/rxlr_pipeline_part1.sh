#!/bin/bash
INPUT=$1

echo "RxLR pipeline- input your sorted contigs as your first file"
echo "Predicting coding seqs- forward"
#~/scripts/rxlr/print_atg_50FaN2.pl $INPUT >atg.fa
echo "REVCOMPing the contigs"
#~/scripts/rxlr/revcomp_fasta.pl $INPUT >contigs_R.fa 
echo "Predicting coding seqs- reverse"
#~/scripts/rxlr/print_atg_50FaN2.pl contigs_R.fa >atg_R.fa
#cat atg.fa atg_R.fa>aa_cat.fa
echo "Signal P- this is now  parallelised"
#~/scripts/rxlr/parallel_signalp.sh 


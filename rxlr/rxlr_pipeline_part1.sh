#!/bin/bash
INPUT=$1
SCRIPT_DIR=$(readlink -f ${0%/*})
SP_DIR=$2

echo $SCRIPT_DIR

echo "RxLR pipeline- input your sorted contigs as your first argument and the path to signalp2 as your second argument"
echo "Predicting coding seqs- forward"
$SCRIPT_DIR/print_atg_50FaN2.pl $INPUT F >atg.fa
echo "REVCOMPing the contigs"
$SCRIPT_DIR/revcomp_fasta.pl $INPUT >contigs_R.fa 
echo "Predicting coding seqs- reverse"
$SCRIPT_DIR/print_atg_50FaN2.pl contigs_R.fa R >atg_R.fa
echo "Joining Forward and Reverse Files"
cat atg.fa atg_R.fa>aa_cat.fa
echo "Cleaning up any old files"
rm -rf ./fasta_seq
echo "Outputting batch FASTA files for Signal P"
$SCRIPT_DIR/run_signalP3.pl aa_cat.fa
echo "Signal P- this is now  parallelised"
$SCRIPT_DIR/parallel_signalp.sh $SP_DIR

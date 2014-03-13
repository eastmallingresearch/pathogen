#!/bin/bash 
#Assemble contigs using velvet and generate summary statistics using process_contigs.pl
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 4
#$ -l virtual_free=4G

WORK_DIR=$TMPDIR
HASH_LENGTH=$1
FORWARD_FILE=$2
REVERSE_FILE=$3
ASSEMBLY_NAME=$4

echo "HASH LENGTH IS  $HASH_LENGTH"
echo "FORWARD FILE IS $FORWARD_FILE"
echo "Reverse file is $REVERSE_FILE"
echo "Assembly name is $ASSEMBLY_NAME"

velveth $WORK_DIR $HASH_LENGTH -fastq -shortPaired -separate $FORWARD_FILE $REVERSE_FILE
velvetg $WORK_DIR -long_mult_cutoff 1 -exp_cov 6 -ins_length 700 -cov_cutoff 2 -min_contig_lgth 750
process_contigs.pl -i $WORK_DIR/contigs.fa -o $ASSEMBLY_NAME.$HASH_LENGTH

rm -R $WORK_DIR



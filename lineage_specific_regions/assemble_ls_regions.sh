#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 8
#$ -l virtual_free=2G

# Assemble ls region
HASH_LENGTH=$1
F_READ=$2
R_READ=$3
EXP_COV=$4
COV_CUT=$5
INS_LGTH=$6

ORGANISM=$(echo $F_READ | rev | cut -d "/" -f4 | rev)
STRAIN=$(echo $F_READ | rev | cut -d "/" -f3 | rev)
Alignment=$(echo $F_READ | rev | cut -d "/" -f2 | rev)
ASSEMBLY_NAME="$STRAIN"_"$Alignment"_ls

CUR_PATH=$PWD
WORK_DIR=$TMPDIR/"$STRAIN"_fastqc

mkdir -p $WORK_DIR
cd $WORK_DIR


cat $CUR_PATH/$F_READ | gunzip -fc > f_read.fastq
cat $CUR_PATH/$R_READ | gunzip -fc > r_read.fastq

velveth $WORK_DIR $HASH_LENGTH -fastq -shortPaired -separate f_read.fastq r_read.fastq
velvetg $WORK_DIR -exp_cov $EXP_COV -cov_cutoff $COV_CUT -ins_length $INS_LGTH -min_contig_lgth 1000
process_contigs.pl -i $WORK_DIR/contigs.fa -o "$ASSEMBLY_NAME"_"$HASH_LENGTH"

rm f_read.fastq
rm r_read.fastq
cp $WORK_DIR/*/sorted_contigs.fa $CUR_PATH/assembly/ls_contigs/$ORGANISM/$STRAIN/$Alignment/"$ASSEMBLY_NAME"_"$HASH_LENGTH".fa
cp $WORK_DIR/*/stats.txt $CUR_PATH/assembly/ls_contigs/$ORGANISM/$STRAIN/$Alignment/"$ASSEMBLY_NAME"_"$HASH_LENGTH".txt
rm -r $TMPDIR
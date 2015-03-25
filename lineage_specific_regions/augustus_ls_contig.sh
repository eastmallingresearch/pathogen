#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 4
#$ -l virtual_free=1G

# Script for submission to SGE for prediction of genes in lineage specific regions.
# This script require Augustus to be installed. The Augustus bin and scripts
# directories must be in the file paths and the path to the augustus config
# directory must be exported from the users ~/.profile . 

USAGE="augustus_ls_contig.sh <species_used_for_training> <in_file>"

MODEL=$1
INFILE=$2



ORGANISM=$(echo $INFILE | rev | cut -d "/" -f4 | rev)
STRAIN=$(echo $INFILE | rev | cut -d "/" -f3 | rev)
Alignment=$(echo $INFILE | rev | cut -d "/" -f2 | rev)
SORTED_CONTIGS=$(echo $INFILE | rev | cut -d "/" -f1 | rev)

CUR_PATH=$PWD
WORK_DIR=$TMPDIR/$STRAIN

mkdir -p $WORK_DIR
cd $WORK_DIR

augustus --codingseq=on --gff3=on --species=$MODEL $CUR_PATH/$INFILE > "$STRAIN"_aug_out.txt
getAnnoFasta.pl "$STRAIN"_aug_out.txt
cat "$STRAIN"_aug_out.txt | grep -v '#' | grep 'AUGUSTUS' > "$STRAIN"_aug_preds.gff

mkdir -p $CUR_PATH/gene_pred/ls_contigs/$ORGANISM/$STRAIN/$Alignment/.
cp $TMPDIR/$STRAIN/* $CUR_PATH/gene_pred/ls_contigs/$ORGANISM/$STRAIN/$Alignment/.
rm -r $WORK_DIR

exit
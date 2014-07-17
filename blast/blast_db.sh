#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 16
#$ -l virtual_free=0.9G



# Create a nucleotide blast database and then perform a nuceotide blast 
# against it.
# Usage: blast_db.sh <query.fa> <target.fa>

#-------------------------------------------------------
# 		Step 0.		Initialise values
#-------------------------------------------------------

CUR_PATH=$PWD
WORK_DIR=/tmp/path_pipe

QUERY=$1
TARGET=$2

ORGANISM=$(echo $TARGET | rev | cut -d "/" -f4 | rev)
STRAIN=$(echo $TARGET | rev | cut -d "/" -f3 | rev)
SORTED_CONTIGS=$(echo $TARGET | rev | cut -d "/" -f1 | rev)

mkdir $WORK_DIR
cd $WORK_DIR
cp $CUR_PATH/$TARGET $SORTED_CONTIGS

#-------------------------------------------------------
# 		Step 1.		Make database
#-------------------------------------------------------

makeblastdb -in $SORTED_CONTIGS -input_type fasta -dbtype nucl -title "$ORGANISM"_"$STRAIN".db -parse_seqids -out "$ORGANISM"_"$STRAIN".db


#-------------------------------------------------------
# 		Step 2.		Blast Search
#-------------------------------------------------------


tblastn -db "$ORGANISM"_"$STRAIN".db -query $QUERY -out "$ORGANISM"_"$STRAIN"_hits.txt -evalue 0.01


#-------------------------------------------------------
# 		Step 3.		Summarise blast
#-------------------------------------------------------

grep '>' P.inf_AVR2.fa > /home/armita/summary.txt
grep -A1 '>' P.inf_AVR2.fa | tail -n 1 | paste /home/armita/summary.txt



#------------------------------------------------------
# 		Step 4.		Cleanup
#------------------------------------------------------

rm $SORTED_CONTIGS
mkdir -p $CUR_PATH/analysis/blast/$ORGANISM/$STRAIN
cp $WORK_DIR/* $CUR_PATH/analysis/blast/$ORGANISM/$STRAIN/.
rm -r $WORK_DIR

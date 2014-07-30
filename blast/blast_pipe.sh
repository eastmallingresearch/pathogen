#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 4
#$ -l virtual_free=1G


# script to run blast homology pipe
# Usage: blast_pip.sh <query.fa> <genome_sequence.fa> <path_to_blast_pipe.sh>


#-------------------------------------------------------
# 		Step 0.		Initialise values
#-------------------------------------------------------

CUR_PATH=$PWD
WORK_DIR=/tmp/blast
IN_QUERY=$1
IN_GENOME=$2
if [ "$3" ]; then SCRIPT_DIR=$3; else SCRIPT_DIR=/home/armita/git_repos/emr_repos/tools/pathogen/blast; fi
ORGANISM=$(echo $IN_GENOME | rev | cut -d "/" -f4 | rev)
STRAIN=$(echo $IN_GENOME | rev | cut -d "/" -f3 | rev)
QUERY=$(echo $IN_QUERY | rev | cut -d "/" -f1 | rev)
GENOME=$(echo $IN_GENOME | rev | cut -d "/" -f1 | rev)
mkdir $WORK_DIR
cd $WORK_DIR
cp $CUR_PATH/$IN_GENOME $GENOME
cp $CUR_PATH/$IN_QUERY $QUERY
OUTNAME="$STRAIN"_"$QUERY"

#-------------------------------------------------------
# 		Step 1.		blast queries against themselves
#-------------------------------------------------------

$SCRIPT_DIR/blast_self.pl $QUERY > "$QUERY"_self.csv

#-------------------------------------------------------
# 		Step 2.		simplify hits table into homolog groups
#-------------------------------------------------------

$SCRIPT_DIR/blast_parse.pl "$QUERY"_self.csv > "$QUERY"_simplified.csv

#-------------------------------------------------------
# 		Step 3.		blast queries against genome
#-------------------------------------------------------

$SCRIPT_DIR/blast2csv.pl $QUERY $GENOME 5 > "$OUTNAME"_hits.csv

#-------------------------------------------------------
# 		Step 4.		combine the homolog group table
#					 with the blast result table
#-------------------------------------------------------

paste -d '\t' "$QUERY"_simplified.csv <(cut -f 2- "$OUTNAME"_hits.csv) > "$OUTNAME"_homologs.csv

#-------------------------------------------------------
# 		Step 5.		Cleanup
#-------------------------------------------------------

mkdir -p $CUR_PATH/analysis/blast_homology/$ORGANISM/$STRAIN/

cp -r $WORK_DIR/"$OUTNAME"_homologs.csv $CUR_PATH/analysis/blast_homology/$ORGANISM/$STRAIN/.

rm -r $WORK_DIR/


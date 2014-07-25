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

#QUERY="P.inf_AVR2.fa"
#GENOME="sorted_contigs.fa"

#-------------------------------------------------------
# 		Step 1.		Make blast databases
#-------------------------------------------------------


makeblastdb -in $QUERY -dbtype prot -out query_db -title query_db
makeblastdb -in $GENOME -dbtype nucl -out genome_db -title genome_db

#-------------------------------------------------------
# 		Step 2.		blast queries against themselves
#-------------------------------------------------------

$SCRIPT_DIR/blast_self.pl $QUERY query_db > "$QUERY"_self.csv

#-------------------------------------------------------
# 		Step 3.		simplify hits table into homolog groups
#-------------------------------------------------------

$SCRIPT_DIR/blast_parse.pl "$QUERY"_self.csv > "$QUERY"_simplified.csv

#-------------------------------------------------------
# 		Step 4.		blast queries against genome
#-------------------------------------------------------

$SCRIPT_DIR/blast2csv.pl $QUERY genome_db > "$OUTNAME"_hits.csv

#-------------------------------------------------------
# 		Step 5.		combine the homolog group table
#					 with the blast result table
#-------------------------------------------------------

paste -d , "$QUERY"_simplified.csv <(cut -f 2- "$OUTNAME"_hits.csv) > "$OUTNAME"_homologs.csv

#-------------------------------------------------------
# 		Step 6.		Cleanup
#-------------------------------------------------------

mkdir -p $CUR_PATH/analysis/blast_homology/$ORGANISM/$STRAIN/

cp -r $WORK_DIR/"$OUTNAME"_homologs.csv $CUR_PATH/analysis/blast_homology/$ORGANISM/$STRAIN/.

rm -r $WORK_DIR/

# rm homology_tmp.csv
# rm query_db*
# rm genome_db*
# rm homology_tab.csv
# rm blast_homologs.csv
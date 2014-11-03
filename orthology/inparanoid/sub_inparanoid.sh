#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 2
#$ -l virtual_free=1G

#-
# 		Submit INPARANOID jobs to the cluster
#-

#-
#	Set variables
#-

USAGE="sub_inparanoid.sh <taxon1_pred_genes.fa> <taxon2_pred_genes.fa> <taxon1_pred_genes.gff> <taxon2_pred_genes.gff>"
INFILE1=$1
INFILE2=$2
FEATURES1=$3
FEATURES2=$4
STRAIN1=$(echo $INFILE1 | rev | cut -d "/" -f2 | rev)
STRAIN2=$(echo $INFILE2 | rev | cut -d "/" -f2 | rev)
FEATURENAME1="$STRAIN1"_uniq_vs_"$STRAIN2"
FEATURENAME2="$STRAIN2"_uniq_vs_"$STRAIN1"

CUR_PATH=$PWD
WORK_DIR=$TMPDIR/"$STRAIN1"-"$STRAIN2"_inparanoid

mkdir -p $WORK_DIR
cd $WORK_DIR

cp /home/armita/prog/inparanoid_4.1/* .
cp $CUR_PATH/$INFILE1 $STRAIN1
cp $CUR_PATH/$INFILE2 $STRAIN2



#-
#	Run INPARANOID
#		- Edit headers of fasta files to allow easier interpretation of output	
#		- The blastall function needs editing to allow multiple cores to be used.
#-

sed "s/>/>$STRAIN1|/" -i $STRAIN1
sed "s/>/>$STRAIN2|/" -i $STRAIN2
sed 's/$blastall = "blastall";/$blastall = "blastall -a2";/' -i inparanoid.pl
./inparanoid.pl $STRAIN1 $STRAIN2

#------------------------------------
#	Process the output table:
#			- Extract a list of all headers in original fasta
#			- Extracting a list of genes with orthologs from the orthology table
#			- Compare this to the headers in the original fasta and identify genes that do not have orthologs between species
#			- Extract .gff features that match unique genes
#			- Remove those genes that don't have both start and stop codons 
#				(as they may not-pass orthology thresholds due to being incomplete genes)
#------------------------------------

#-
#	For $STRAIN1
#-
grep '>' $STRAIN1 | sed 's/>//' > "$STRAIN1"_seqs.txt
cut -f3 table."$STRAIN1"-"$STRAIN2" | sed "s/ $STRAIN1/\n$STRAIN1/g" | cut -d' ' -f1 | tail -n+2 | cat - "$STRAIN1"_seqs.txt | sort | uniq -u > "$STRAIN1"_uniq_vs_"$STRAIN2".txt
cat "$STRAIN1"_uniq_vs_"$STRAIN2".txt | cut -d '|' -f2 | xargs -I{} grep -w {} $CUR_PATH/$FEATURES1 | sed "s/AUGUSTUS/$FEATURENAME1/" > "$STRAIN1"_uniq_vs_"$STRAIN2".gff
/home/armita/git_repos/emr_repos/tools/seq_tools/feature_annotation/filter_gff_StartStop.pl "$STRAIN1"_uniq_vs_"$STRAIN2".gff > "$STRAIN1"_uniq_vs_"$STRAIN2"_filtered.gff

#-
#	For $STRAIN2
#-
grep '>' $STRAIN2 | sed 's/>//' > "$STRAIN2"_seqs.txt
cut -f4 table."$STRAIN1"-"$STRAIN2" | sed "s/ $STRAIN2/\n$STRAIN2/g" | cut -d' ' -f1 | tail -n+2 | cat - "$STRAIN2"_seqs.txt | sort | uniq -u > "$STRAIN2"_uniq_vs_"$STRAIN1".txt
cat "$STRAIN2"_uniq_vs_"$STRAIN1".txt | cut -d '|' -f2 | xargs -I{} grep -w {} $CUR_PATH/$FEATURES2 | sed "s/AUGUSTUS/$FEATURENAME2/" > "$STRAIN2"_uniq_vs_"$STRAIN1".gff
/home/armita/git_repos/emr_repos/tools/seq_tools/feature_annotation/filter_gff_StartStop.pl "$STRAIN2"_uniq_vs_"$STRAIN1".gff > "$STRAIN2"_uniq_vs_"$STRAIN1"_filtered.gff


#-
#	Identify gene duplications
#-

grep "1.000 $STRAIN1" table."$STRAIN1"-"$STRAIN2" > "$STRAIN1"_duplications.txt
grep "1.000 $STRAIN2" table."$STRAIN1"-"$STRAIN2" > "$STRAIN2"_duplications.txt
cat "$STRAIN1"_duplications.txt "$STRAIN2"_duplications.txt | sort | uniq > "$STRAIN1"-"$STRAIN2"_duplications.txt


#-
#	Return output
#-

mkdir -p $CUR_PATH/analysis/inparanoid/"$STRAIN1"-"$STRAIN2"

cp -r $WORK_DIR/error.log $CUR_PATH/analysis/inparanoid/"$STRAIN1"-"$STRAIN2"/.
cp -r $WORK_DIR/orthologs* $CUR_PATH/analysis/inparanoid/"$STRAIN1"-"$STRAIN2"/.
cp -r $WORK_DIR/Output* $CUR_PATH/analysis/inparanoid/"$STRAIN1"-"$STRAIN2"/.
cp -r $WORK_DIR/sqltable* $CUR_PATH/analysis/inparanoid/"$STRAIN1"-"$STRAIN2"/.
cp -r $WORK_DIR/table* $CUR_PATH/analysis/inparanoid/"$STRAIN1"-"$STRAIN2"/.

cp -r $WORK_DIR/"$STRAIN1" $CUR_PATH/analysis/inparanoid/"$STRAIN1"-"$STRAIN2"/.
cp -r $WORK_DIR/"$STRAIN1"-* $CUR_PATH/analysis/inparanoid/"$STRAIN1"-"$STRAIN2"/.
cp -r $WORK_DIR/"$STRAIN1"_* $CUR_PATH/analysis/inparanoid/"$STRAIN1"-"$STRAIN2"/.

cp -r $WORK_DIR/"$STRAIN2" $CUR_PATH/analysis/inparanoid/"$STRAIN1"-"$STRAIN2"/.
cp -r $WORK_DIR/"$STRAIN2"-* $CUR_PATH/analysis/inparanoid/"$STRAIN1"-"$STRAIN2"/.
cp -r $WORK_DIR/"$STRAIN2"_* $CUR_PATH/analysis/inparanoid/"$STRAIN1"-"$STRAIN2"/.

rm -r $TMPDIR
exit




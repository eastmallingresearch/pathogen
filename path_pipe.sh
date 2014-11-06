#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 1
#$ -l virtual_free=0.9G
#$ -M andrew.armitage@emr.ac.uk
#$ -m abe



#######  Step 1	 ########
# Initialise values		#
#########################

CUR_PATH=$PWD
IN_FILE=$1

SCRIPT_DIR=/home/armita/git_repos/emr_repos/tools/pathogen/rxlr
SIG_P=$CUR_PATH/signalp-2.0/signalp

ORGANISM=$(echo $IN_FILE | rev | cut -d "/" -f4 | rev)
STRAIN=$(echo $IN_FILE | rev | cut -d "/" -f3 | rev)
SORTED_CONTIGS=$(echo $IN_FILE | rev | cut -d "/" -f1 | rev)

WORK_DIR=$TMPDIR/path_pipe_"$STRAIN"

mkdir -p $WORK_DIR
cd $WORK_DIR
cp $CUR_PATH/$IN_FILE $SORTED_CONTIGS

echo $SORTED_CONTIGS
echo "The following files are present in the temporary directory:"
ls

#########################################################################

#########################################################################


#######  Step 1	 ########
# Run RXLR part1		#
#########################

# RxLR pipeline- input your sorted contigs as your first argument and the path to 
# signalp2 as your second argument"


# /home/armita/git_repos/pathogen/rxlr/rxlr_pipeline_part1.sh $SORTED_CONTIGS $SIG_P


echo $SCRIPT_DIR


	#######  Step 1a ########
	# find open reading 	#
	# frames in contigs and #
	# translate these to AA	#
	#########################

echo "RxLR pipeline- input your sorted contigs as your first argument and the path to signalp2 as your second argument"
echo "Predicting coding seqs- forward"
/home/armita/git_repos/emr_repos/scripts/phytophthora/pathogen/rxlr/print_atg_gff.pl $SORTED_CONTIGS F "$STRAIN"_F_atg.fa "$STRAIN"_F_atg_nuc.fa "$STRAIN"_F_atg_ORF.gff

	#######  Step 1b ########
	# revcomp contigs to get#
	# reads on the R strand #
	# of DNA				#
	#########################


echo "REVCOMPing the contigs"
$SCRIPT_DIR/revcomp_fasta.pl $SORTED_CONTIGS > contigs_R.fa

 
	#######  Step 1c ########
	# find open reading 	#
	# frames in revcomp		#
	# contigs and translate	# 
	# these to AA			#
	#########################
	
	
echo "Predicting coding seqs- reverse"
/home/armita/git_repos/emr_repos/scripts/phytophthora/pathogen/rxlr/print_atg_gff.pl contigs_R.fa R "$STRAIN"_R_atg.fa "$STRAIN"_R_atg_nuc.fa "$STRAIN"_R_atg_ORF.gff

 
	#######  Step 1d ########
	# concatenate files of	#
	# open reading frames	#
	#########################

echo "Joining Forward and Reverse Files"
cat "$STRAIN"_F_atg.fa "$STRAIN"_R_atg.fa > $STRAIN.aa_cat.fa
cat "$STRAIN"_F_atg_nuc.fa "$STRAIN"_R_atg_nuc.fa > "$STRAIN"_nuc.fa
cat "$STRAIN"_F_atg_ORF.gff "$STRAIN"_R_atg_ORF.gff > "$STRAIN"_ORF.gff

	#######  Step 1e ########
	# 		Cleanup			#
	#########################

echo "Cleaning up any old files"
rm -rf ./fasta_seq


	#######  Step 1f ########
	# Split ORF files into  #
	# batches of 500 		#
	# 		proteins		#
	#########################
	
echo "Outputting batch FASTA files for Signal P"
$SCRIPT_DIR/run_signalP3.pl $STRAIN.aa_cat.fa

	#######  Step 1g ########
	# Run Signal P on 		#
	# batched protein files	#
	#########################



OUTPUT_FILE=$STRAIN.sp.out

echo "hash_length N50"

for FAA_FILE in $( ls ./fasta_seqs/*.faa ); do
    echo "Looking at $FAA_FILE" 
	$SIG_P -t euk -f summary -trunc 70 $FAA_FILE > $FAA_FILE."out"
done 




#########################################################################

#########################################################################


#######  Step 2	 ########
# Run RXLR part2		#
#########################

	#######  Step 2b ########
	# 	Concatenate batch	#
	# SGE files into single #
	# outfile				#
	#########################

echo "Concatonating files"
cat fasta_seqs/*.faa.out > $OUTPUT_FILE


	#######  Step 2c ########
	# 	Annotate AA file with
	#	signalP	output data #
	#########################
	
	
echo "Annotating signal p data "
tail -n +5 $OUTPUT_FILE > $STRAIN.f.out
$SCRIPT_DIR/annotate_signalP2hmm3_v3.pl $STRAIN.f.out $STRAIN.sp.tab $STRAIN.sp.pve $STRAIN.sp.nve $STRAIN.aa_cat.fa

	#######  Step 2d ########
	# 	motif search for	#
	# rxlrs in aa sequence	#
	#########################

echo "RxLR prediction" 
$SCRIPT_DIR/find_rxlr_v2.pl $STRAIN.sp.pve $STRAIN.sp.rxlr $STRAIN.sp.sum_rxlr

tail -n +2 $STRAIN.sp.rxlr | head -n -1 > "$STRAIN"_sp_rxlr.fa



#########################################################################

#########################################################################

#######  Step 3	 ########
# Run MIMP detection	#
#########################

	#######  Step 3a ########
	# 	motif search for	#
	# MIMPs in aa sequence	#
	#########################

$SCRIPT_DIR/../mimp_finder/mimp_finder.pl $SORTED_CONTIGS $STRAIN.mimps.fa

tail -n +2 $STRAIN.mimps.fa | head -n -1 > "$STRAIN"_mimps.fa

#########################################################################

#########################################################################


#######  Step 4	 ########
# Pull out nucleotide 	#
# sequence containting 
# 	rxlr/mimps			#
#########################

grep '>' "$STRAIN"_sp_rxlr.fa | cut -f1 > id_tmp.txt
printf "" > "$STRAIN"_sp_rxlr_nuc.fa
while read line; do
	grep -A1 "$line" "$STRAIN"_nuc.fa >> "$STRAIN"_sp_rxlr_nuc.fa
done<id_tmp.txt
rm id_tmp.txt

grep '>' "$STRAIN".mimps.fa | cut -f1 > id_tmp.txt
printf "" > "$STRAIN"_mimps_nuc.fa
while read line; do
	grep -A1 "$line" "$STRAIN"_nuc.fa >> "$STRAIN"_mimps_nuc.fa
done<id_tmp.txt
rm id_tmp.txt

#######  Step 5	 ########
# 		Cleanup			#
#########################


mkdir -p $CUR_PATH/analysis/rxlr/$ORGANISM/$STRAIN/

cp -r $WORK_DIR/. $CUR_PATH/analysis/rxlr/$ORGANISM/$STRAIN/.

rm -r $TMPDIR



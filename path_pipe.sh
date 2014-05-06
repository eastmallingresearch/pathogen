#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 16
#$ -l virtual_free=0.9G
#$ -M andrew.armitage@emr.ac.uk
#$ -m abe



#######  Step 1	 ########
# Initialise values		#
#########################

CUR_PATH=$PWD
WORK_DIR=/tmp/path_pipe

IN_FILE=$1

SCRIPT_DIR=/home/armita/git_repos/pathogen/rxlr
SIG_P=/home/groups/harrisonlab/project_files/alternaria/signalp-2.0/signalp

ORGANISM=$(echo $IN_FILE | rev | cut -d "/" -f3 | rev)
STRAIN=$(echo $IN_FILE | rev | cut -d "/" -f2 | rev)
SORTED_CONTIGS=$(echo $IN_FILE | rev | cut -d "/" -f1 | rev)

mkdir $WORK_DIR
cd $WORK_DIR
cp $CUR_PATH/$IN_FILE .




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
$SCRIPT_DIR/print_atg_50FaN2.pl $SORTED_CONTIGS F > atg.fa

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
$SCRIPT_DIR/print_atg_50FaN2.pl contigs_R.fa R >atg_R.fa

 
	#######  Step 1d ########
	# concatenate files of	#
	# open reading frames	#
	#########################

echo "Joining Forward and Reverse Files"
cat atg.fa atg_R.fa>aa_cat.fa

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
$SCRIPT_DIR/run_signalP3.pl aa_cat.fa

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

#	/home/armita/git_repos/pathogen/rxlr/rxlr_pipeline_part2.sh


SCRIPT_DIR=/home/armita/git_repos/pathogen/rxlr


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
$SCRIPT_DIR/find_rxlr_v2.pl $STRAIN.sp.pve $STRAIN.sp.rxlr




#########################################################################

#########################################################################

#######  Step 3	 ########
# Run MIMP detection	#
#########################

	#######  Step 3a ########
	# 	motif search for
	# MIMPs in aa sequence	#
	#########################

/home/armita/git_repos/pathogen/mimp_finder/mimp_finder.pl $SORTED_CONTIGS $STRAIN.mimps.fa



#########################################################################

#########################################################################

#######  Step 4	 ########
# 		Cleanup			#
#########################


mkdir $CUR_PATH/analysis/rxlr/$ORGANISM

mkdir $CUR_PATH/analysis/rxlr/$ORGANISM/$STRAIN/

cp -r $WORK_DIR/. $CUR_PATH/analysis/rxlr/$ORGANISM/$STRAIN/.

rm -r $WORK_DIR/



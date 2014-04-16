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
SIG_P=/home/master_files/prog_master/bin

ORGANISM=$(echo $IN_FILE | cut -d "/" -f3)
STRAIN=$(echo $IN_FILE | cut -d "/" -f4)
SORTED_CONTIGS=$(echo $IN_FILE | cut -d "/" -f5)

mkdir $WORK_DIR
cd $WORK_DIR
cp $CUR_PATH/$IN_FILE .

#######  Step 1	 ########
# Run RXLR part1		#
#########################

# RxLR pipeline- input your sorted contigs as your first argument and the path to 
# signalp2 as your second argument"


/home/armita/git_repos/pathogen/rxlr/rxlr_pipeline_part1.sh $SORTED_CONTIGS $SIG_P


#######  Step 1	 ########
# Run RXLR part2		#
#########################

/home/armita/git_repos/pathogen/rxlr/rxlr_pipeline_part2.sh

#######  Step 1	 ########
# Run MIMP detection	#
#########################

/home/armita/git_repos/pathogen/mimp_finder.pl $SORTED_CONTIGS $STRAIN_mimps.fa

#######  Step 1	 ########
# 		Cleanup			#
#########################


mkdir $CUR_PATH/analysis/rxlr/$ORGANISM/$STRAIN/

cp -r $WORK_DIR/. $CUR_PATH/analysis/rxlr/$ORGANISM/$STRAIN/.

rm -r $WORK_DIR/



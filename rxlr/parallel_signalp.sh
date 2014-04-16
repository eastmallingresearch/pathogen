#!/bin/bash

OUTPUT_FILE=all_sp.out
SCRIPT_DIR=/home/armita/git_repos/pathogen/rxlr
SP_DIR=$1
echo "hash_length N50"

for DIR in $( ls ./fasta_seqs/*.faa ); do
	(
    echo "Looking at $DIR"
<<<<<<< HEAD
	 $SCRIPT_DIR/submit_signalp.sh $DIR $SP_DIR ) &
	 if (( $DIR % 16 == 0 )); then wait; fi # Limit to 16 concurrent subshells.
=======
	 $SCRIPT_DIR/submit_signalp.sh $DIR $SP_DIR  &
	 if (( $DIR % 16 == 0 )); then wait; fi )# Limit to 16 concurrent subshells.
>>>>>>> 47c5dd194f9ad3148da3a0c95c057ea2bb1aa8f8

done 

#cat *.faa.out>$OUTPUT_FILE

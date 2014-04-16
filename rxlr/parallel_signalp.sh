#!/bin/bash

OUTPUT_FILE=all_sp.out
SCRIPT_DIR=/home/armita/git_repos/pathogen/rxlr
SP_DIR=$1
echo "hash_length N50"

for DIR in $( ls ./fasta_seqs/*.faa ); do
	(
    echo "Looking at $DIR"
	 $SCRIPT_DIR/submit_signalp.sh $DIR $SP_DIR ) &
	 if (( $DIR % 8 == 0 )); then wait; fi # Limit to 8 concurrent subshells.

done 

#cat *.faa.out>$OUTPUT_FILE

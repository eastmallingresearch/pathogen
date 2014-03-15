#!/bin/bash

OUTPUT_FILE=all_sp.out
SCRIPT_DIR=$(readlink -f ${0%/*})
SP_DIR=$1
echo "hash_length N50"

for DIR in $( ls ./fasta_seqs/*.faa ); do

    echo "Looking at $DIR"
    #~/signalp-2.0/signalp -t euk -f summary -trunc 70 $DIR > $DIR."out"
    qsub $SCRIPT_DIR/submit_signalp.sh $DIR $SP_DIR

done 

#cat *.faa.out>$OUTPUT_FILE

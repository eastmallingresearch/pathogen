#!/bin/bash

OUTPUT_FILE=all_sp.out
echo "hash_length N50"

for DIR in $( ls ./fasta_seqs/*.faa ); do

    echo "Looking at $DIR"
    #~/signalp-2.0/signalp -t euk -f summary -trunc 70 $DIR > $DIR."out"
    qsub ~/scripts/rxlr/submit_signalp.sh $DIR

done 

#cat *.faa.out>$OUTPUT_FILE

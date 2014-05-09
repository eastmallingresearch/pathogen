#!/bin/bash

OUTPUT_FILE=all_sp.out
SCRIPT_DIR=$(readlink -f ${0%/*})
SP_DIR=$1
echo "hash_length N50"

for DIR in $( ls ./fasta_seqs/*.faa ); do
<<<<<<< HEAD

    echo "Looking at $DIR"
    #~/signalp-2.0/signalp -t euk -f summary -trunc 70 $DIR > $DIR."out"
    qsub $SCRIPT_DIR/submit_signalp.sh $DIR $SP_DIR
=======
    echo "Looking at $DIR"
	qsub $SCRIPT_DIR/submit_signalp.sh $DIR $SP_DIR

#	 ( $SCRIPT_DIR/submit_signalp.sh $DIR $SP_DIR )  &
#	 if (( $DIR % 16 == 0 )); then wait; fi # Limit to 16 concurrent subshells.
>>>>>>> 81452ad2079ec086f96b83d2a32e221b985e5a89

done 

cat *.faa.out>$OUTPUT_FILE

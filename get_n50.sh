#!/bin/bash

OUTPUT_FILE=n50.dat
echo "hash_length N50"> $OUTPUT_FILE

for DIR in $( ls -d P.cact.auto.* ); do
	HASH_LENGTH=$( echo $DIR | cut -f4 -d'.' )
	STATS_FILE=$DIR/stats.txt
	N50=$( head -n1 $STATS_FILE | cut -f2 -d' ')
	# echo "dir = $DIR and hash length = $HASH_LENGTH"
	echo "$HASH_LENGTH $N50" >> $OUTPUT_FILE

done 

#!/bin/bash
#submit multiple jobs to cluster

FORWARD_FILE=P.cact_411_1M_F_trim.fastq
REVERSE_FILE=P.cact_411_1M_R_trim.fastq
ASSEMBLY_NAME=Pcact.auto
cd $PWD

for HASH_LENGTH in $( seq 35 10 65); do
qsub ~/scripts/align.sh $HASH_LENGTH $FORWARD_FILE $REVERSE_FILE $ASSEMBLY_NAME
done


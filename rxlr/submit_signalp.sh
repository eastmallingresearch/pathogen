#!/bin/bash

#Assemble contigs using velvet and generate summary statistics using process_contigs.pl
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 16
#$ -l virtual_free=1G

FILE_NAME=$1

~/signalp-2.0/signalp -t euk -f summary -trunc 70 $FILE_NAME > $FILE_NAME."out"

#!/bin/bash

# submit assemblies to path_pipe.sh for rxlr and MIMP prediction.
# for the best assembly in the velvet folder for each genome assembly
# perform the path_pipe.sh script

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"	

for ASSEMBLY in assembly/velvet/*/*; do
	STRAIN=$(echo $ASSEMBLY | cut -d "/" -f4)
	HIGHEST_N50=$(cat "$ASSEMBLY"/"$STRAIN"_assembly_stats.txt | tail -n +2 | sort -gk 4,4 | tail -n 1 | cut -f 3)
	qsub $SCRIPT_DIR/path_pipe.sh "$ASSEMBLY"/"$STRAIN"_assembly."$HIGHEST_N50"/sorted_contigs.fa
done
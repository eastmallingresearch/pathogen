#!/bin/bash

# script to run blast homology pipe
# Usage: blast_pip.sh <query.fa> <genome_sequence.fa>

QUERY=$1
GENOME=$2

#QUERY="P.inf_AVR2.fa"
#GENOME="sorted_contigs.fa"

makeblastdb -in $QUERY -dbtype prot -out query_db -title query_db

./blast_self.pl $QUERY query_db > homology_tmp.csv

./blast_parse.pl homology_tmp.csv > homology_tab.csv

makeblastdb -in $GENOME -dbtype nucl -out genome_db -title genome_db

./blast2csv.pl $QUERY genome_db > blast_homologs.csv

paste -d , homology_tab.csv <(cut -f 2- blast_homologs.csv) > blast_homology_output.csv

rm homology_tmp.csv
rm query_db*
rm genome_db*
rm homology_tab.csv
rm blast_homologs.csv

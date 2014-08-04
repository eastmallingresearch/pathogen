#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 4
#$ -l virtual_free=1G

#	blast_differentials.sh summarises the results of blast.sh accross multiple genomes.
#	It will indicate the presence/absence of blast results from each genome and output 
#	three files (tab delimited presence/absence in each genome): present_all.csv - 
#	genes present in all genomes; absent_all.csv - genes absent in all genomes; 
#	differentials.csv - genes present in some, but not all genomes.


#-------------------------------------------------------
# 		Step 1.		Collect a list of input files; 
#		Loop through them, splitting them into lists
#		of queries with hits/no hits and also make a 
#		list of all query names for differentials file
#		later.
#-------------------------------------------------------


for INFILE in $@; do
	head -n1 $INFILE | cut -f1 > "$INFILE"_present.csv
	head -n1 $INFILE | cut -f1 > "$INFILE"_absent.csv
	head -n1 $INFILE | cut -f1 > presence_"$INFILE".csv	
	while read line; do
		ID=$(printf $line | cut -d' '  -f1)
		HIT=$(echo $line | cut -d' ' -f1020)
		if [ "$HIT" != "0" ]; then
			printf "$ID" >> "$INFILE"_present.csv
			printf "\n" >> "$INFILE"_present.csv
			printf "$ID""\t1\n" >> presence_"$INFILE".csv
		else
			printf "$ID" >> "$INFILE"_absent.csv
			printf "\n" >> "$INFILE"_absent.csv
			printf "$ID""\t0\n" >> presence_"$INFILE".csv
		fi
	done<$INFILE
done 

#-------------------------------------------------------
# 		Step 2.		Combine the total lists together to
#		make a .csv table of presence/absence of each query
#-------------------------------------------------------

NUMBER=1
cut -f1 "$1" > tmp_tab"$NUMBER".csv
for INFILE in $@; do
	NEXT_NUM=$((NUMBER+1))
	paste -d '\t' tmp_tab"$NUMBER".csv <(cut -f2 presence_"$INFILE".csv) > tmp_tab"$NEXT_NUM".csv
	NUMBER=$((NUMBER+1))
done


#-------------------------------------------------------
# 		Step 2.		Split the total list into lists of
#		genes that are present in all genomes, absent 
#		in all genomes, or are differential.
#-------------------------------------------------------

mv tmp_tab"$NEXT_NUM".csv presence_tab.csv
rm tmp_tab*
grep -P '\s0\s0\s0\s0' presence_tab.csv > absent_all.csv
grep -P '\s1\s1\s1\s1' presence_tab.csv > present_all.csv
grep -vP '\s0\s0\s0\s0' presence_tab.csv | grep -vP '\s1\s1\s1\s1' > differentials.csv


exit
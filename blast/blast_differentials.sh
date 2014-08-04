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

USAGE="blast_differentials.sh <blast_pipe_outfile.csv> <blast_pipe_outfile.csv> <blast_pipe_outfile.csv>"

echo "$USAGE"
echo ""
echo "Have you remembered to edit line 42?"
echo "the number of the column which containins the number of hits in <blast_pipe_outfile.csv>?"
echo "(Edit the number after -f)" 
echo ""
echo "Have you remembered to edit the grep expressions on lines 83-85?"
echo '(These require a \s0 and \s1 for each genome you input)'

#-------------------------------------------------------
# 		Step 1.		Collect a list of input files; 
#		Loop through them, splitting them into lists
#		of queries with hits/no hits and also make a 
#		list of all query names for differentials file
#		later.
#-------------------------------------------------------
#
#	
#
#

for INFILE in $@; do
	head -n1 $INFILE | cut -f1 > "$INFILE"_present.csv
	head -n1 $INFILE | cut -f1 > "$INFILE"_absent.csv
	head -n1 $INFILE | cut -f1 > "$INFILE"_presence.csv
	while read line; do
		ID=$(printf $line | cut -d' '  -f1)
		HIT=$(echo $line | cut -d' ' -f1020)		# Edit this line before running.
		if [ "$HIT" != "0" ]; then
			printf "$ID" >> "$INFILE"_present.csv
			printf "\n" >> "$INFILE"_present.csv
			printf "$ID""\t1\n" >> "$INFILE"_presence.csv
		else
			printf "$ID" >> "$INFILE"_absent.csv
			printf "\n" >> "$INFILE"_absent.csv
			printf "$ID""\t0\n" >> "$INFILE"_presence.csv
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
	paste -d '\t' tmp_tab"$NUMBER".csv <(cut -f2 "$INFILE"_presence.csv) > tmp_tab"$NEXT_NUM".csv
	NUMBER=$((NUMBER+1))
done


#-------------------------------------------------------
# 		Step 2.		Split the total list into lists of
#		genes that are present in all genomes, absent 
#		in all genomes, or are differential.
#-------------------------------------------------------
#
#	ESSENTIAL
#		Grep expressions must be edited before running.
#		These require a \s0 and \s1 for each genome in
#		the analysis
#

mv tmp_tab"$NEXT_NUM".csv presence_tab.csv
rm tmp_tab*
grep -P '\s0\s0\s0\s0\s0\s0\s0\s0\s0\s0' presence_tab.csv > absent_all.csv		# Edit this line before running
grep -P '\s1\s1\s1\s1\s1\s1\s1\s1\s1\s1' presence_tab.csv > present_all.csv		# Edit this line before running
grep -vP '\s0\s0\s0\s0\s0\s0\s0\s0\s0\s0' presence_tab.csv | grep -vP '\s1\s1\s1\s1\s1\s1\s1\s1\s1\s1' > differentials.csv	# Edit this line before running


exit
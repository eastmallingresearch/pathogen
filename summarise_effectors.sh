#!/bin/bash
# A script to view the number of genes, signal peptides and effectors identified by path_pipe	

echo -e "Organism\tStrain\tGenes_predicted\tSignal_P_hits\tRxLR_hits\tMIMP_hits" > analysis/rxlr/effector_summary.tab

for IN_DIR in analysis/rxlr/*/*; do
	ORGANISM=$(echo $IN_DIR | rev | cut -d "/" -f2 | rev)
	STRAIN=$(echo $IN_DIR | rev | cut -d "/" -f1 | rev)
	
	GENE_PRED=$(grep -c ">" $IN_DIR/$STRAIN.aa_cat.fa) 
	SIG_P=$(grep -c ">" $IN_DIR/$STRAIN.sp.pve)
	RXLR=$(grep -c ">" $IN_DIR/$STRAIN.sp.rxlr)
	MIMP=$(tail -n1 $IN_DIR/$STRAIN.mimps.fa | cut -d " " -f3) 
	
	echo -e "$ORGANISM\t$STRAIN\t$GENE_PRED\t$SIG_P\t$RXLR\t$MIMP" >> analysis/rxlr/effector_summary.tab

done



# for each line in file1
# 	grep column 1
# 		if match
# 			split line match
# 			extract match header name
# 			extract match rxlr position
# 			print to header name, YES and rxlr position
# 		if non match
# 			print to file2 line in file1
# 			print to file2 NO
# paste file1(column1,2) file2(column2, 3) to file3
# 
# SIG_P_FILE=analysis/rxlr/A.alternata_ssp._arborescens/675/675.sp.tab
# RXLR_FILE=analysis/rxlr/A.alternata_ssp._arborescens/675/675.sp.rxlr
# 
# 
# for LINE in $(cat $SIG_P_FILE | tail -n +2 | cut -f 1); do	
# 	HIT=$(grep $LINE $RXLR_FILE | rev | cut -d " " -f1 | rev)
# 	if [ -n "$HIT" ]; then
# 		echo "$LINE	YES	$HIT" >> rxlr_hit.tab
# 	elif [ -z "$HIT" ]; then
# 		echo "$LINE	NO	$HIT" >> rxlr_hit.tab
# 	fi
# done
# 
# echo "Gene	Signal_peptide	Cleavage_site	RXLR	Location" > summary_file.tab
# pr $(cat $SIG_P_FILE | tail -n +2 | cut -f1,2,4) rxlr_hit.tab >> summary_file.tab


	


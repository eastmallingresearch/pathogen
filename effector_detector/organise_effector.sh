tr -d ' ' <hop_list.txt >out.txt
awk -F "\t" '{print ">"$1."_"$2."_"$3."\n"$4}' out.txt >hop.fasta
cut -f1 hop_list.txt |sort|uniq >unique.txt
#makeblastdb -in sorted_contigs.fasta -dbtype nucl  -out ps_aq
#blastall -p tblastn -d ps_aq -i ~/git_master/pathogen/effector_detector/hop.fasta -o outputfile


tr -d ' ' <hop_list.txt >out.txt
awk -F "\t" '{print ">"$1."_"$2."_"$3."\n"$4}' out.txt >hop.fasta
cut -f1 hop_list.txt |sort|uniq >unique.txt


#BLAST and then pick best hits
formatdb -i contigs.fa -p F -o F
blastall -p tblastn -i PI_T30-4_r2_2_18155.faa -d contigs.fan -o PI_to_tblastn_contigs.output -e 0.1 -F F
perl /home/idris/kamoun_scripts/blastp2tab11.pl PI_to_tblastn_contigs.output > PI_T30-4_r2_2_18155_tblastn_Pfragariae.output.tab


#Pexfinder
/home/idris/scripts_KamounLab/print_atg_50FaN2.pl /home/idris/richard/contigs.fa >fragariae.faa
revcom contigs.fa contigs_R.fa
/home/idris/scripts_KamounLab/print_atg_50FaN2.pl /home/idris/richard/contigs_R.fa >fragariae_R.faa

/home/idris/scripts_KamounLab//run_signalP3.pl fragariae_cat.faa  &

cat *.faa.out >fragariae.out
cp ./fasta_seqs/fragariae.out .

remove #signal p - header

/home/idris/scripts_KamounLab/annotate_signalP2hmm3.pl

/home/idris/scripts_KamounLab/annotate_signalP2hmm3_v2.pl fragariae.out fragariae.sp.tab fragariae.sp.pve fragariae.sp.nve fragariae.sp.faa

/home/idris/scripts_KamounLab/annotate_signalP2hmm3_v2.pl ./fasta_seqs/1_500.faa.out test.sp.tab test.sp.out.pve test.sp.out.nve test.sp

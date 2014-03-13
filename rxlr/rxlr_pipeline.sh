#!/bin/bash
INPUT=$1

echo "RxLR pipeline- input your sorted contigs as your first file"
echo "Predicting coding seqs- forward"
#~/scripts/rxlr/print_atg_50FaN2.pl $INPUT >atg.fa
echo "REVCOMPing the contigs"
#~/scripts/rxlr/revcomp_fasta.pl $INPUT >contigs_R.fa 
echo "Predicting coding seqs- reverse"
#~/scripts/rxlr/print_atg_50FaN2.pl contigs_R.fa >atg_R.fa
#cat atg.fa atg_R.fa>aa_cat.fa
echo "Signal P- this can be parallelised"
#~/scripts/rxlr/run_signalP3.pl ~/signalp-2.0/ aa_cat.fa
~/scripts/rxlr/parallel_signalp.sh 
rm -f submit_*
cd fasta_seqs
cat *.faa.out >all.out
cd ..
mv ./fasta_seqs/all.out .
echo "Annotating signal p data "
~/scripts/rxlr/annotate_signalP2hmm3_v2.pl all.out all.sp.tab all.sp.pve all.sp.nve all.sp.faa




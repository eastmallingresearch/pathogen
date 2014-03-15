#!/bin/bash

rm -f submit_*
cd fasta_seqs
cat *.faa.out >all.out
cd ..
mv ./fasta_seqs/all.out .
echo "Annotating signal p data - this script needs work"
~/scripts/rxlr/annotate_signalP2hmm3_v2.pl all.out all.sp.tab all.sp.pve all.sp.nve aa_cat.fa



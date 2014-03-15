#!/bin/bash
echo "Tidying SGE files"
rm -f submit_*
echo "Concatonating files"
cat ./fasta_seqs/*.faa.out >all.out
echo "Annotating signal p data - this script needs work"
#~/git_stuff/scripts/rxlr/annotate_signalP2hmm3_v2.pl all.out all.sp.tab all.sp.pve all.sp.nve aa_cat.fa
~/git_stuff/scripts/rxlr/find_rxlr_v2.pl all.sp.pve all.sp.rxlr

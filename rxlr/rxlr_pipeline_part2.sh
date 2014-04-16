#!/bin/bash
SCRIPT_DIR=/home/armita/git_repos/pathogen/rxlr
echo "Tidying SGE files"
rm -f submit_*
echo "Concatonating files"
cat ./fasta_seqs/*.faa.out >all.out
echo "Annotating signal p data "
tail -n +5 all.out>all.f.out
$SCRIPT_DIR/annotate_signalP2hmm3_v3.pl all.f.out all.sp.tab all.sp.pve all.sp.nve aa_cat.fa
echo "RxLR prediction" 
$SCRIPT_DIR/find_rxlr_v2.pl all.sp.pve all.sp.rxlr


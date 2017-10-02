#!/usr/bin/python
'''
This script searches for RxLR motifs within amino acid sequences.
It annotates the position of the RxLR sequence within the genes.
It also notes the presence  of EER domains and their positions.

The program usage is:
rxlr_finder.py [protein_file.fa] > RxLR_outfile.fa
'''

# import modules incl biopython
from Bio import SeqIO
from Bio import motifs
import sys
import re
from os import path

motif="R.LR"

# Open fasta file
filename = sys.argv[1]
with open(filename) as file:


# For fasta accesion
    for rec in SeqIO.parse(file,"fasta"):
        seq = str(rec.seq)
# Identify the position of the signal P cleavage site
        sigpHit = re.search(r"(--Signal_peptide_length=.*?)(\d+)", rec.description)
        sigpEnd = sigpHit.group(2)
        # Bhattacharjee 2006 / Whisson 2007 RxLR location
        minPos = int(sigpEnd)
        maxPos = int(sigpEnd) + 100
        # Win 2006 RxLR location
        # minPos = 29
        # maxPos = 59
        rxlrExp = r"^.{" + str(minPos) + ',' + str(maxPos) + r"}?R.LR"
# Search within the sequence for RxLR.
        match = re.search((rxlrExp), seq)
        if match:
            print(">" + rec.description),
            # Record position of RxLR
            motifPos = (len(match.group()) - 4)
            print "\t--RxLR_start: " + str(motifPos) ,

# if the sequence has an RxLR, then
	# Search for a [D]EER motif after the RxLR.
	# Note the position of the EER motif and the variant that matched the query.
            hitDEER = re.search(r"(R.LR.{,40}([ED][ED][KR]))", str(rec.seq))
            if hitDEER:
                fullDEER = re.search(r"(([ED][ED]+[KR]))", str(rec.seq))
                print "\t--EER_motif_start(" + fullDEER.group(1) + "): " + str((motifPos + (len(hitDEER.group(0)) - (len(fullDEER.group(1)))))) ,
	# print the modified header and sequence
            print ""
            print str(rec.seq)

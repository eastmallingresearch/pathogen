#!/usr/bin/python
'''
This script searches for RxLR motifs within amino acid sequences.
It annotates the position of the RxLR sequence within the genes.
It also notes the presence  of WL motifs and DEER domains and
their positions.

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
#expression=

# Open fasta file
filename = sys.argv[1]
with open(filename) as file:


# For fasta accesion
    for rec in SeqIO.parse(file,"fasta"):
        # print rec.id
        seq = str(rec.seq)
# Identify the position of the signal P cleavage site
        sigpHit = re.search(r"(--Signal_peptide_length=.*?)(\d+)", rec.description)
        sigpEnd = sigpHit.group(2)
        minPos = int(sigpEnd) #+ 30
        maxPos = int(sigpEnd) + 100
        # maxPos = 100
        rxlrExp = r"^.{" + str(minPos) + ',' + str(maxPos) + r"}?R.LR"
        # 		print rxlrExp
# Search within the sequence for RxLR.
#		match = re.search(r".{35,100}R.LR", seq)
        match = re.search((rxlrExp), seq)
        if match:
            print(">" + rec.description),
            # print(">" + "text"),
            # print ">" + rec.description ,
            # print ("> + text"),
            # Note position of RxLR
            motifPos = (len(match.group()) - 4)
            print "\t--RxLR_start: " + str(motifPos) ,

# if the sequence has an RxLR, then
	# Search for a [D]EER motif after the RxLR.
	# Note the position of the EER motif and the variant that matched the query.
#			hitDEER = re.search(r"(^.{,40}([ED][ED][KR])", str(rec.seq))
            hitDEER = re.search(r"(R.LR.{,40}([ED][ED][KR]))", str(rec.seq))
            # hitDEER = re.search(r"(^.{" + str(motifPos) + "," + str(motifPos + 40) + "}?([ED][ED][KR]))", str(rec.seq))
            if hitDEER:
                # print "\t--EER_motif_start(" + hitDEER.group(2) + "): " + str((len(hitDEER.group(1)) - (len(hitDEER.group(2))))) ,
                fullDEER = re.search(r"(([ED][ED]+[KR]))", str(rec.seq))
                # print "\t--EER_motif_start(" + hitDEER.group(2) + "): " + str((len(hitDEER.group(1)) - (len(hitDEER.group(2)))))
                print "\t--EER_motif_start(" + fullDEER.group(1) + "): " + str((motifPos + (len(hitDEER.group(0)) - (len(fullDEER.group(1)))))) ,
 			# 	print hitDEER.group(0)
 			# 	print str(len(hitDEER.group(0)))


				#print str(len(hitDEER.group(1)))
 			# 	print hitDEER.group(0)
 			# 	print str(len(hitDEER.group(0)))
 			# 	print hitDEER.group(1)
 			# 	print str(len(hitDEER.group(1)))
 			# 	print hitDEER.group(2)
 			# 	print str(len(hitDEER.group(2)))
				#lenDEER =
			#motifPos = (len(match.group()) - 4)


	# Search for WL motifs within the sequence following the RxLR
	# Note the number of WL motifs and the position of each of these.
#			hitWY = [m.start() for m in re.finditer('WY', str(rec.seq))]
# 			hits = m in re.finditer(
#			if hitWY: print "\t--WY_start: " + str(hitWY).strip('[]') ,
			#m.start() for m in hitWL,
	# Retrieve the accession header
	# Modify the header to include fields of
	#'--RxLR_start: $pos --EER_var: $str --EER_start: $pos --WL_pos: $pos;$pos;$pos'
	# print the modified header and sequence
            print ""
            print str(rec.seq)

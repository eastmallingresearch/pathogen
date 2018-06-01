#!/usr/bin/python

'''
This tool uses an orthology group txt file output from OrthoMCl to extract
fasta accessions from a goodProteins.fa file.
'''

from sets import Set
import sys,argparse
from collections import defaultdict
import re

#----------------------------------------------
# Step 1
# Import variables & load input files
#-----------------------------------------------------

ap = argparse.ArgumentParser()
ap.add_argument('--gloome',required=True,type=str,help='gloome output')
ap.add_argument('--orthogroups',required=True,type=str,help='text file output of OrthoMCl orthogroups')
ap.add_argument('--OrthoMCL_all',required=True,type=str,nargs='+',help='The identifiers of all strains used in the orthology analysis')
conf = ap.parse_args()

with open(conf.orthogroups) as f:
    orthogroup_lines = f.readlines()

with open(conf.gloome) as f:
    gloome_lines = f.readlines()

# gloome_set = set()
gloome_dict = defaultdict(str)
for line in gloome_lines:
    line = line.rstrip()
    split_line = line.split("\t")
    position = split_line[1]
    # gloome_set.add(position)
    gloome_dict[position] = split_line[0]

all_isolates = conf.OrthoMCL_all
# orthogroup_content_dict = defaultdict(list)
clade_dict = defaultdict(int)
for line in orthogroup_lines:
    line = line.rstrip("\n")
    split_line = line.split(" ")
    orthogroup_id = split_line[0].replace(":", "")
    position = orthogroup_id.replace("orthogroup", "")
    # if position in gloome_set:
    if gloome_dict[position]:
        gain_loss = gloome_dict[position]
        # print line
        orthogroup_contents = []
        # orthogroup_content_dict.clear()
        clade_dict.clear()
        for isolate in all_isolates:
            num_genes = line.count((isolate + "|"))
            orthogroup_contents.append(str(isolate) + "(" + str(num_genes) + ")")
            content_counts = ":".join(orthogroup_contents)
            # orthogroup_content_dict[isolate] = num_genes
            content_str = ",".join(split_line[1:])
            if num_genes > 0:
                # isolate_clade = isolate.split('_')[0]
                isolate_clade = re.sub(r"\d+\b", "", isolate)
                clade_dict[isolate_clade] += 1
        # all_clades = [x.split("_")[0] for x in all_isolates]
        all_clades = [re.sub(r"\d+\b", "", x) for x in all_isolates]
        seen = set()
        clade_counts = []
        for clade in all_clades:
            if clade in seen:
                continue
            else:
                seen.add(clade)
            num_isolates = clade_dict[clade]
            clade_counts.append("".join([clade, "(", str(num_isolates), ")"]))
        clade_str = "".join(clade_counts)
        # clade_dict.clear()
        # for transcript_id in split_line[1:]:
        #     clade_id=transcript_id.split('_')[0]
        #     clade_dict[clade_id] += 1

        print "\t".join([position, gain_loss, orthogroup_id, clade_str, content_counts, content_str])

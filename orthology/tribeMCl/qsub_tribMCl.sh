#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 1
#$ -l virtual_free=1G


set -u
set -e
set -o pipefail

Usage='qsub_tribemcl.sh <merged_file_of_blast_hits.tsv> [Inflation value (1-5)]'

# ----------------------	Step 1	----------------------
# 		Set Variables
#
#-------------------------------------------------------

MergeHits=$1
# The inflation value determines the tightness of your clusters
#   - If higher you will have smaller and more closely-related clusters
Inflation='1.5'
if $2; then
  Inflation=$2
fi

IsolateAbrv=$(echo $GoodProts | rev | cut -f3 -d '/' | rev)

CurPath=$PWD
WorkDir=$TMPDIR/tribemcl
OutDir=$CurPath/analysis/orthology/tribemcl/$IsolateAbrv
mkdir -p $WorkDir
cd $WorkDir

OrthoGroups="$IsolateAbrv"_orthogroups.txt
OrthoMatrix="$IsolateAbrv"_orthogroups.tab

echo "$Usage"
echo ""
echo "The following inputs were given:"
echo "MergeHits = $MergeHits"
echo "GoodProts = $GoodProts"
echo "Inflation value = $Inflation"
echo "output will be copied to:"
echo "OutDir = $OutDir"
echo "Files this script will make:"
# echo "Config = $Config"
# echo "SimilarGenes = $SimilarGenes"
# echo "Log_file = $Log_file"
# echo "MclInput = $MclInput"
# echo "MclOutput = $MclOutput"
# echo "OrthoGroups = $OrthoGroups"
# echo "OrthoMatrix = $OrthoMatrix"


# ----------------------	Step 3	----------------------
#    Run orthoMCL
#         a) parse blast hits
#         c) Identify pairs of homologous genes
#         e) Cluster pairs of homologs into orthogroups
#         f) Parse the OrthoMCL orthogroup output into
#             a matrix that cam be opened in R.
#-------------------------------------------------------

#-- a --
mkdir -p blastHitDir
cp $CurPath/$MergeHits blastHitDir/blast_table.tab
cat blastHitDir/blast_table.tab | cut -f1,2,11 | clusterx --method mcl -p inflation=5 - > $OrthoGroups


# ----------------------	Step 4	----------------------
#    Copy orthomcl output into an output directory
#    & cleanup
#-------------------------------------------------------

rm -r blastHitDir
mkdir -p $OutDir
mv $WorkDir/* $OutDir/.

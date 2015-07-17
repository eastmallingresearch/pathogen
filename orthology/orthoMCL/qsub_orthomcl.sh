#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 1
#$ -l virtual_free=1G


set -u
set -e
set -o pipefail

Usage='qsub_orthomcl.sh <merged_file_of_blast_hits.tsv> <directory_containing_good_proteins>'

# ----------------------	Step 1	----------------------
# 		Set Variables
#
#-------------------------------------------------------

MergeHits=$1
GoodProts=$2
# MergeHits=analysis/orthology/orthomcl/Pcac_Pinf_Pram_Psoj/Pcac_Pinf_P.ram_P.soj_blast.tab
# GoodProts=analysis/orthology/orthomcl/Pcac_Pinf_Pram_Psoj/goodProteins/goodProteins.fasta
IsolateAbrv=$(echo $MergeHits | rev | cut -f2 -d '/' | rev)

CurPath=$PWD
WorkDir=$TMPDIR/orthomcl
# CurPath=/home/groups/harrisonlab/project_files/idris
# WorkDir=/tmp/orthomcl
OutDir=$CurPath/analysis/orthology/orthomcl/$IsolateAbrv
mkdir -p $WorkDir
cd $WorkDir

Config="$IsolateAbrv"_orthomcl.config
SimilarGenes="$IsolateAbrv"_similar.txt
Log_file="$IsolateAbrv"_orthoMCL.log
MclInput="$IsolateAbrv"_mclInput
MclOutput="$IsolateAbrv"_mclOutput
OrthoGroups="$IsolateAbrv"_orthogroups.txt
OrthoMatrix="$IsolateAbrv"_orthogroups.tab



echo "$Usage"
echo ""
echo "The following inputs were given:"
echo "MergeHits = $MergeHits"
echo "GoodProts = $GoodProts"
echo "output will be copied to:"
echo "OutDir = $OutDir"
echo "Files this script will make:"
echo "Config = $Config"
echo "SimilarGenes = $SimilarGenes"
echo "Log_file = $Log_file"
echo "MclInput = $MclInput"
echo "MclOutput = $MclOutput"
echo "OrthoGroups = $OrthoGroups"
echo "OrthoMatrix = $OrthoMatrix"


# ----------------------	Step 2	----------------------
#    Compy the template orthomcl config
#    & Edit fields in this file
#-------------------------------------------------------

cp /home/armita/testing/armita_orthomcl/orthomcl.config $Config
sed -i "s/similarSequencesTable=.*/similarSequencesTable="$IsolateAbrv"_SimilarSequences_spoons/g" $Config
sed -i "s/orthologTable=.*/orthologTable="$IsolateAbrv"_Ortholog_spoons/g" $Config
sed -i "s/inParalogTable=.*/inParalogTable="$IsolateAbrv"_InParalog_spoons/g" $Config
sed -i "s/coOrthologTable=.*/coOrthologTable="$IsolateAbrv"_CoOrtholog_spoons/g" $Config
sed -i "s/interTaxonMatchView=.*/interTaxonMatchView="$IsolateAbrv"_interTaxonMatch_spoons/g" $Config

~/prog/orthomcl/orthomclSoftware-v2.0.9/bin/orthomclInstallSchema $Config install_schema.log


# ----------------------	Step 3	----------------------
#    Run orthoMCL
#         a) parse blast hits
#         b) Load blast results into a database
#         c) Identify pairs of homologous genes
#         d) Write output from the database
#         e) Cluster pairs of homologs into orthogroups
#         f) Parse the OrthoMCL orthogroup output into
#             a matrix that cam be opened in R.
#-------------------------------------------------------

#-- a --
mkdir -p goodProtDir
cp $CurPath/$GoodProts goodProtDir/.
orthomclBlastParser $CurPath/$MergeHits goodProtDir >> $SimilarGenes
#-- b --
ls -lh $SimilarGenes # The database will be 5x the size of this file = ~2.5Gb
orthomclLoadBlast $Config $SimilarGenes
#-- c --
orthomclPairs $Config $Log_file cleanup=yes #<startAfter=TAG>
#-- d --
orthomclDumpPairsFiles $Config
mv mclInput $MclInput
#-- e --
mcl $MclInput --abc -I 1.5 -o $MclOutput
cat $MclOutput | orthomclMclToGroups orthogroup 1 > $OrthoGroups
#-- f --
GitDir=~/git_repos/emr_repos/tools/pathogen/orthology/orthoMCL
$GitDir/orthoMCLgroups2tab.py $CurPath/$GoodProts $OrthoGroups > $OrthoMatrix


# ----------------------	Step 4	----------------------
#    Copy orthomcl output into an output directory
#    & cleanup
#-------------------------------------------------------

rm -r goodProtDir
mkdir -p $CurPath/$OutDir
mv $WorkDir $CurPath/$OutDir

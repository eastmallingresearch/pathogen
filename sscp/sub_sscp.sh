#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 1
#$ -l virtual_free=1G

Usage="sub_sscp.sh <secreted_proteins.fasta>"

ProtFile=$1

ProgPath=/home/armita/git_repos/emr_repos/tools/pathogen/sscp
Organism=$(echo $ProtFile | rev | cut -d "/" -f3 | rev)
Strain=$(echo $ProtFile | rev | cut -d "/" -f2 | rev)
CurPath=$PWD
WorkDir=$TMPDIR/"$Strain"_sscp
OutDir=$CurPath/analysis/sscp/$Organism/$Strain


mkdir -p $WorkDir
cd $WorkDir

cp $CurPath/$ProtFile prot.fasta

"$ProgPath"/sscp_filter.py prot.fasta > "$Strain"_sscp.fasta

mkdir -p $OutDir
cp "$Strain"_sscp.fasta $OutDir/.
rm -r $TMPDIR
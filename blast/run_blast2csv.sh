#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 1
#$ -l virtual_free=0.9G
#$ -l h=blacklace02.blacklace|blacklace03.blacklace|blacklace04.blacklace|blacklace06.blacklace|blacklace07.blacklace|blacklace08.blacklace|blacklace09.blacklace|blacklace10.blacklace


# script to run blast homology pipe
USAGE="run_blast2csv.sh <Query.fa> <dna, protein (QueryFormat)> <Genome_sequence.fa> <output_directory>"


#-------------------------------------------------------
# 		Step 0.		Initialise values
#-------------------------------------------------------

InQuery=$1
QueryFormat=$2
InGenome=$3
Organism=$(echo $InGenome | rev | cut -d "/" -f4 | rev)
Strain=$(echo $InGenome | rev | cut -d "/" -f3 | rev)
Query=$(echo $InQuery | rev | cut -d "/" -f1 | rev)
Genome=$(echo $InGenome | rev | cut -d "/" -f1 | rev)
CurPath=$PWD



Outname="$Strain"_"$Query"
ProgDir=$HOME/git_repos/emr_repos/tools/pathogen/blast

if [ "$4" ]; then
  OutDir=$CurPath/$4;
else
  OutDir=$CurPath/analysis/blast_homology/$Organism/$Strain;
fi
WorkDir=$TMPDIR/blast_"$Strain"


if test "$QueryFormat" = 'protein'; then
	BlastType='tblastn'
elif test "$QueryFormat" = 'dna'; then
	BlastType='tblastx'
else
  exit
fi

echo "Running blast_pipe.sh"
echo "Usage = $USAGE"
echo "Organism is: $Organism"
echo "Strain is: $Strain"
echo "Query is: $Query"
echo "This is $QueryFormat data"
echo "Genome is: $Genome"
echo "You are running scripts from:"
echo "$ProgDir"

mkdir -p $WorkDir
cd $WorkDir
# ls -lh $CurPath/$InGenome
# ls -lh $CurPath/$InQuery
cp $CurPath/$InGenome $Genome
cp $CurPath/$InQuery $Query

#-------------------------------------------------------
# 		Step 1.		blast queries against Genome
#-------------------------------------------------------

$ProgDir/blast2csv.pl $Query $BlastType $Genome 5 > "$Outname"_hits.csv


#-------------------------------------------------------
# 		Step 2.		Cleanup
#-------------------------------------------------------

mkdir -p $OutDir/.

cp -r $WorkDir/"$Outname"_hits.csv $OutDir/.

rm -r $WorkDir/

#!/usr/bin/bash
#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -pe smp 3
#$ -l virtual_free=1G


USAGE='bowtie2_alignment_pipe.sh <F_reads_to_align.fq> <R_reads_to_align.fq> <subject_genome.fa>'
echo $USAGE
F_READS_IN=$1
R_READS_IN=$2
GENOME_IN=$3

ORGANISM1=$(echo $F_READS_IN | rev | cut -d "/" -f4 | rev)
STRAIN1=$(echo $F_READS_IN | rev | cut -d "/" -f3 | rev)
F_FILE="$STRAIN1"_F_reads.fq
R_FILE="$STRAIN1"_R_reads.fq

ORGANISM2=$(echo $GENOME_IN | rev | cut -d "/" -f3 | rev)
STRAIN2=$(echo $GENOME_IN | rev | cut -d "/" -f2 | rev)
GENOME_FILE=$(echo $GENOME_IN | rev | cut -d "/" -f1 | rev)

GENOME_INDEX="$STRAIN2"_bowtie_index
SAM_FILE="$STRAIN1"_vs_"$STRAIN2"

CUR_PATH=$PWD
WORK_DIR=$TMPDIR/bowtie2_"$SAM_FILE"

mkdir -p $WORK_DIR
cd $WORK_DIR

#fastq-mcf /home/armita/git_repos/emr_repos/tools/seq_tools/illumina_full_adapters.fa $CUR_PATH/$F_READS_IN $CUR_PATH/$R_READS_IN -o $F_FILE -o $R_FILE -C 1000000 -u -k 20 -t 0.01 -q 30
cat $CUR_PATH/$F_READS_IN | gunzip -c -f > $F_FILE
cat $CUR_PATH/$F_READS_IN | gunzip -c -f > $R_FILE
cp $CUR_PATH/$GENOME_IN $GENOME_FILE 

bowtie2-build $GENOME_FILE $GENOME_INDEX
bowtie2 -x $GENOME_INDEX -1 $F_FILE -2 $R_FILE -S "$SAM_FILE".sam  -p 3 --un-conc "$SAM_FILE"_unaligned.fastq
samtools view -bS "$SAM_FILE".sam > "$SAM_FILE".bam
samtools sort "$SAM_FILE".bam "$SAM_FILE"_sorted
samtools index "$SAM_FILE"_sorted.bam
samtools faidx $GENOME_FILE
#samtools tview "$SAM_FILE"_sorted.bam $GENOME_FILE
samtools idxstats "$SAM_FILE"_sorted.bam > "$SAM_FILE"_sorted_indexstats.csv
/home/armita/git_repos/emr_repos/scripts/alternaria/assembly/divide_col.py "$SAM_FILE"_sorted_indexstats.csv 1 2 > "$SAM_FILE"_sorted_indexstats_coverage.csv
printf "occurence\taligned_reads_per_base\n" > "$SAM_FILE"_reads_per_base.csv
cat "$SAM_FILE"_sorted_indexstats_coverage.csv | cut -f5 | sort -n | uniq -c | sed 's/ *//' | sed 's/ /\t/g' >> "$SAM_FILE"_reads_per_base.csv
cat "$SAM_FILE"_sorted_indexstats_coverage.csv | cut -f2,5 | grep -w '0' | cut -f1 | python -c"import sys; print(sum(map(int, sys.stdin)))"
cat "$SAM_FILE"_sorted_indexstats_coverage.csv | cut -f1,5 | grep -w '0' | grep -v '*' | cut -f1 > "$STRAIN2"_ls_contigs.txt
/home/armita/git_repos/emr_repos/tools/pathogen/lineage_specific_regions/find_novel_reads.py "$STRAIN2"_ls_contigs.txt $GENOME_FILE -fa > "$STRAIN2"_ls_contigs.fa

mkdir -p $CUR_PATH/assembly/ls_contigs/$ORGANISM1/$STRAIN1/vs_"$STRAIN2"_contigs
cp "$SAM_FILE"* $CUR_PATH/assembly/ls_contigs/$ORGANISM1/$STRAIN1/vs_"$STRAIN2"_contigs/.
cp "$STRAIN2"_ls_contigs.fa $CUR_PATH/assembly/ls_contigs/$ORGANISM1/$STRAIN1/vs_"$STRAIN2"_contigs/.
rm -r $WORK_DIR/
#!/usr/bin/perl -w
#
use strict;
use warnings;
#
#
#-------------------------------------------------------------------------
# run_signalP2.pl
#
#
# Conditions:
# 1. this script file exists in the same
#    directory as signalP folder.
# 3. fasta file name ends with ".fa", eg my_seq.fa
# 
#
#
# Usage: ./run_signalP2.pl
#
# !!!Warning: there is no checking for validity of input/output files
#
# Written by Joe Win, Kamoun Lab, OARDC, OSU.
#
#-------------------------------------------------------------------------
#

my $line = "";
my $seqName = "";
my @seqNames = ();
my @aaSeqs = ();
my $thisSeq = "";
my $total = 0;
my $currDir = shift;;
chop $currDir;
$currDir .= '/';


my $signalP = $currDir.'signalp';

my $fastaFile = "";


#-------------------------------------------------------------------------

	# Asks for a fasta input file containing 
	# amino acid sequences
	#
print "\n";
$fastaFile = shift;;
chomp $fastaFile;
unless ( open ( FASTAFILE, "$fastaFile" ) ) {
    print "Cannot open file \"$fastaFile\"\n";
    exit;
}
	# collect sequences in two parallel arrays:
	# one for names and one for aa sequences.
	#
my $inSequence = 0;
my $seqComplete = 0;
my $totalSeqCount = 0;
my $tempSeq = "";
my @sequences;

while (<FASTAFILE>) {
    chomp;
    $line = $_;
    if ($line =~ /^>/) {
        if ($inSequence) {
            $inSequence = 0;
            $seqComplete = 1;
        } else {
            $inSequence = 1;
            $seqComplete = 0;
        }
        $line .= "\n";
    } else {
        $inSequence = 1;
    }
    
    if ($inSequence) {
        $tempSeq .= "$line";
    }
    
    if ($seqComplete) {
        push @sequences, "$tempSeq";
        $tempSeq = "$line";
        $seqComplete = 0;
        $inSequence = 0;
        $totalSeqCount++;
    }
}
push @sequences, "$tempSeq";
$totalSeqCount++;
print "There are $totalSeqCount sequences in the file\n";
close FASTAFILE;


#-------------------------------------------------------------------------

	# writes out individual fasta files containing 500 sequences each
	# into a directory (in this case ./fasta_seqs/).
	# 
my $seqDir = "fasta_seqs";
my $ok = `mkdir $seqDir`;
$total = @sequences;
print "There are $total sequences in the file\n";
my $seqCount = 0;
my $fileCount = 0;
my $seqFile = 0;
my $manySeqs = '';
for ( my $i = 0; $i < $total; $i++ ){
    $thisSeq = $sequences[$i]."\n";
    $manySeqs .= $thisSeq;
    $seqCount++;
    if ($seqCount == 500) {
        $fileCount++;
        $seqName = $fileCount.'_500'.'.faa';
        $seqFile = $seqDir.'/'.$seqName;
        open ( OUTPUT, ">$seqFile");
        print OUTPUT $manySeqs;
        close OUTPUT;
        $manySeqs = '';
        $seqCount = 0;
    }
}
if (($seqCount < 500) && ($seqCount != 0)) {
        $fileCount++;
        $seqName = $fileCount.'_500'.'.faa';
        $seqFile = $seqDir.'/'.$seqName;
        open ( OUTPUT, ">$seqFile");
        print OUTPUT $manySeqs;
        close OUTPUT;
        $seqCount = 0;
}

#-------------------------------------------------------------------------


	# calls signalP for each fasta file containing the
	# 500 fasta protein sequences.
	# signalP stdout is redirected to a file 
	#

opendir(DIR,$seqDir);
my @seqFileNames = readdir(DIR);

closedir(DIR);
for (@seqFileNames) {
    next if ($_ eq "." || $_ eq "..");
    print "$_\n";
    my $options = "-t euk -f summary -trunc 70 $seqDir/$_ > $seqDir/$_".".out\n" ;
    print "$signalP $options $_\n";
    my $whatever = `$signalP $options`;
 }
   
#-------------------------------------------------------------------------

    
exit;

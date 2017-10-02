#!/usr/bin/perl -w
#
use strict;
use warnings;
#
#
#-----------------------------------------------------------------------------
# annotate_signalP2hmm.pl
#
# Preparation needed for the input file:
#      1. remove header and the first "-{70}" line.
#      2. put "---- (70 characters)" line at the end of the file.
#
#	Usage:	just type "./annotate_signalP2hmm.pl" (without quotes) at the
#			command prompt and answer questions accordingly.
#
#
#	Written by Joe Win @ Kamoun Lab, OARDC, Ohio State University
#	Currently this script extract and annotate SignalP 2.0 positives
#	(HMM score > 0.9 and signal cleavage site >10, <40.
#	Please modify according to your specifications.
#
#------------------------------------------------------------------------------


# Asks for a file containing the signalP results
#
print "\nPlease enter the file containing the signalP result: ";
my $signalpResultFile = shift;
chomp $signalpResultFile;
unless (-e $signalpResultFile) {die "Can't open $signalpResultFile: $!"}

# Asks for the output file name to store signalP positives.
#
print "Please enter the file name for signalP output in tabular form: ";
my $outFile = shift;
chomp $outFile;

# Asks for the output file name to store signalP positives.
#
print "Please enter the file name for signalP positives: ";
my $outFile2 = shift;
chomp $outFile2;

# Asks for the output file name to store signalP negatives.
#
print "Please enter the file name for signalP negatives: ";
my $outFile3 = shift;
chomp $outFile3;


# Asks for the fasta file containing the sequences.
print "Please enter the fasta file to annotate: ";
my $fasta = shift;
chomp $fasta;
unless (-e $fasta) {die "Can't open $fasta: $!"}

open(INPUT, $signalpResultFile) || die "Can't open $signalpResultFile: $!";
my @results;
my $theseLines = "";
my $total = 0;
while (<INPUT>) {
    $theseLines .= $_;
    if (/^-{70}/) {
        $total++;
        push (@results, $theseLines);
        $theseLines = "";
    }
}
close (INPUT);

my $header = "";
my $seqCount = 0;
my $seq = "";
my %sequences = ();
my $unique_ID = 0;
my $inSequence = 0;
open (FASTA, "$fasta") || die "Can't open $fasta: $!";
while (<FASTA>) {
    chomp;
    if (/^>/) {
        if ($inSequence) {
	    # stops collecting the sequence lines and store
	    # the sequence in a hash with the unique ID in its header line
	    # as its key.
	    	$unique_ID = $header;
	    	$unique_ID =~ s/\|/_/g;
	    	($unique_ID) = split (" ", $unique_ID);
	    	#print "$unique_ID\n";
	    	$seq = $header."\n".$seq."\n";
	    	if (exists $sequences{$unique_ID}) {
	    		print "********** This $unique_ID sequence is duplicated **********\n";
	    	} else {
	    		$sequences{$unique_ID} = $seq;
	    		$seqCount++;
	    	}
	        $seq = "";
	      	$unique_ID = 0;
	        $inSequence = 0;
		}
		if (!$inSequence) {
			$header = $_;
			$inSequence = 1;
		}
	} else {
    # collects the lines following the matching header line.
        $seq .= $_;
    }
}
# capture the last sequence entry...
$unique_ID = $header;
$unique_ID =~ s/\|/_/g;
($unique_ID) = split (" ", $unique_ID);
#print "$unique_ID\n";
$seq = $header."\n".$seq."\n";
$sequences{$unique_ID} = $seq;

close FASTA;


my $thisResult = "";
my $cleaveSite = 0;
my $probability = 0;
my @signalPeptides;
my @noPex;
my @toPrint;
my $thisName = "";
$unique_ID = "";
$seq = "";

for (@results) {
    $thisResult = $_;
    $thisResult =~ /(>.*)\n\n/gm;
    $thisName = "$1";
    $unique_ID = $thisName;
	$unique_ID =~ s/\|/_/g;
	($unique_ID) = split (" ", $unique_ID);
    #    print "$unique_ID\n";
    #    print "*********************$thisResult\n" if (!($unique_ID =~ />/));
    if ($thisResult =~ /\# Most likely cleavage site between pos. (\d\d)/) {
        $cleaveSite = $1;
    #} elsif ($thisResult =~ /Max cleavage site probability: \d+.\d+ between pos. (\d+)/) {
    #    $cleaveSite = $1;
    } else {
    	$cleaveSite = 41;
    }
    my $signalPeptide = ($thisResult =~ /Prediction: Signal peptide/);
    $thisResult =~ /Signal peptide probability: (\d\.\d\d\d)/;
    $probability = "$1";
    if (($signalPeptide) && ($cleaveSite < 41) && ($cleaveSite > 9) && ($probability >= 0.9)) {
    # if (($signalPeptide) {
    	if (exists $sequences{$unique_ID}) {
    		$seq = $sequences{$unique_ID};
    		$seq =~ s/^(>.*?)\n/$1 \t--HMM_score=\t$probability\t--Signal_peptide_length=\t$cleaveSite\n/gm;
        	push (@signalPeptides, $seq);
        }
        $thisName .= "\tYES\t$probability\t$cleaveSite\n";
        push (@toPrint, $thisName);
    } else {
        $thisName .= "\tNo\t$probability\t$cleaveSite\n";
        push (@toPrint, $thisName);
        if (exists $sequences{$unique_ID}) {
    		$seq = $sequences{$unique_ID};
        	push (@noPex, $seq);
        }

    }
}
print "There are $total results from $seqCount sequences\n";

open (OUT, ">$outFile") || die "Can't create output file $outFile: $!";
print OUT "Query name\tSignal peptide probability(SignalP-HMM)\tCleavage site\n";
print OUT @toPrint;
close (OUT);
$total = @signalPeptides;

open (OUT, ">$outFile2") || die "Can't create output file $outFile2: $!";
print "There are $total signalP positives\n";
print OUT @signalPeptides;
close (OUT);

open (OUT, ">$outFile3") || die "Can't create output file $outFile3: $!";
$total = @noPex;
print "There are $total signalP negatives\n";
print OUT @noPex;
close (OUT);

exit;

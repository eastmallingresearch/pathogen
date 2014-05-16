#!/usr/bin/perl -w
#
use strict;
use warnings;
#
#
#-------------------------------------------------------------------------
# find_rxlr.pl
#
my $seqName = "";
my @seqNames = ();
my $aaSeq = "";
my @aaSeqs = ();
my $total = 0;

# reads a fasta file containing one or more aa sequences.
#
#print "\n\*\* Please enter the name of fasta protein file: ";
my $fastaFile = shift;
chomp $fastaFile;


#print "\n\*\* Please enter a name of file to store results: ";
my $outFile = shift;
chomp $outFile;

# Collect a second output file from the given inputs to make a summary file.
my $summary_out = shift;
chomp $summary_out; 

open (FASTA_FILE, "$fastaFile") || die "Cannot open file \"$fastaFile\"\n\n";
while (<FASTA_FILE>) {
        # collect sequences in two parallel arrays:
        # one for names and one for aa sequences.
    chomp;

    if (/^>.*/) {
        push @seqNames, $_;
    } else {
        push @aaSeqs, $_;
    }
}
close FASTA_FILE;


open (OUT, ">$outFile") || die "Cannot open file \"$outFile\"\n\n";
print OUT "Following FASTA files contain the effector motif...\n";
open (SUM_OUT, ">$summary_out") || die "Cannot open file \"$summary_out\"\n\n";
print SUM_OUT "Gene	RXLR_present	Position_in_seq\n";

my $subSeq;
my $effectorCount = 0;
my $DE_count = 0;
my $i = 0;
my $DE_percent = 0;
my $seqLen = 0;
$total = @seqNames;
for ($i = 0; $i < $total; $i++) {
    $seqName = $seqNames[$i];
    $aaSeq = $aaSeqs[$i];
    if ($aaSeq =~ /^[a-yA-Y]{10,110}?R[A-Y]LR/g) {
    	my $RXLR_pos = pos($aaSeq) - 3 ;
        #$subSeq = $1;
        #$seqLen = length ($subSeq);
        #print "$seqName contains $subSeq\n";
        #$DE_count = ($subSeq =~ tr /DEde//);        
        #print "Number of D or E = $DE_count\n";
        #$DE_percent = int( ($DE_count / $seqLen) * 100 );
        #print "D or E comprise $DE_percent\n";
        #if ($DE_percent >= 25) {
            $effectorCount++;
            print OUT "$seqName	--RXLR_starts_at	$RXLR_pos\n";
            print SUM_OUT "$seqName	YES	$RXLR_pos\n";
            for (my $pos = 0; $pos < length($aaSeq); $pos += 300) {
                print OUT substr($aaSeq, $pos, 300), "\n";
            }
            #}
            #print OUT "$aaSeq\n";
            #print "D or E comprise $DE_percent%\n";
    } else {
    	print SUM_OUT "$seqName NO	-";
    }
    
}
print OUT "There are $effectorCount sequences that contain the effector motif\n";
close (OUT);

exit;


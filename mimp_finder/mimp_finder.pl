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
my $dnaSeq = "";
my @dnaSeqs = ();
my $total = 0;
my $tempSeq=();
my $thisLine=();
my $inSequence = 0;
my $seqComplete = 0;

# reads a fasta file containing one or more DNA sequences.;
my $fastaFile = shift;
chomp $fastaFile;

#print "\n\*\* Please enter a name of file to store results: ";
my $outFile = shift;
chomp $outFile;

open (FASTA_FILE, "$fastaFile") || die "Cannot open file \"$fastaFile\"\n\n";

my $flag=0;

while (<FASTA_FILE>) {
        # collect sequences in two parallel arrays:
        # one for names and one for aa sequences.
    	    chomp;
    	$thisLine = $_;
    	
	if ($thisLine =~ /^>/ && $flag==0) {
		#print "START LINE DETECTED $thisLine \n";
		#$thisLine .= "\n";	
		push (@seqNames, $thisLine);
		$flag=1;
        	}
	elsif ( $thisLine =~ /^>/ && $flag==1){
		# print "START LINE DETECTED $thisLine \n";
		 push (@seqNames, $thisLine);
		 push (@dnaSeqs,$tempSeq);
		 $tempSeq=();
		}
	else {
        	$tempSeq .= "$thisLine";
    	}
	
}
#print "PUSHING FINAL LINE\n";
push (@dnaSeqs,$tempSeq);
close FASTA_FILE;

print "SEQUENCES IN NAME ARRAY  ".scalar(@seqNames)."\n";
print "SEQUENCES IN SEQS ARRAY  ".scalar(@seqNames)."\n";

open (OUT, ">$outFile") || die "Cannot open file \"$outFile\"\n\n";
print OUT "Following FASTA files contain the mimp motif...\n";

my $subSeq;
my $mimpCount = 0;
my $i = 0;
$total = @seqNames;



for ($i = 0; $i < $total; $i++) {
#for ($i = 140; $i < 141; $i++) {
    #print "Working on $seqNames[$i] \n";
    $seqName = $seqNames[$i];
    $dnaSeq = $dnaSeqs[$i];
  
	while ($dnaSeq =~/CAGTGGG..GCAA[TA]AA/g ){
		my $mimp_pos = pos($dnaSeq) ;
		print "FOUND MIMP on $seqName at $mimp_pos\n";
         	$mimpCount=$mimpCount+1;;
		print OUT "$seqName --mimp starts at $mimp_pos\.\n";
            		print OUT substr($dnaSeq, ($mimp_pos-16), 80), "\n";
                    		
	}
	while ($dnaSeq =~/TT[TA]TTGC..CCCACTG/g ){
                my $mimp_pos = pos($dnaSeq) ;
                print "FOUND MIMP on $seqName at $mimp_pos\n";
                $mimpCount=$mimpCount+1;;
                print OUT "$seqName --mimp starts at $mimp_pos\.\n";
                        print OUT substr($dnaSeq, ($mimp_pos-16), 80), "\n";

        }

    
}

print OUT "There are $mimpCount sequences that contain the consensus mimp motif\n";
print "There are $mimpCount sequences that contain the consensus mimp motif\n";
close (OUT);

exit;


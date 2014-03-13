#!/usr/bin/perl -w
#
#
use warnings;
use strict;
#
#
#
#--------------------------------------------------------------------------
# blastp2tab10.pl
#--------------------------------------------------------------------------
#
# Parses the NCBI-BLAST out-put file into a tabular form with
# following annotations in order:
# Query, Query Length, Matching Subject, Subject Length, Bit Score,
# E-value, Percent Match, Number of Matching aa/Nucleotides, Length of
# the HSP. (You can add more if you want by modifying the sub.)
#
# Extracts the top hit.
#
# Usage: ./blast2tab.pl blast_result_file > output_tab_file
#
#
#
# Written by Joe Win, Kamoun's lab, Plant Pathology, OARDC, OSU.
# Date: 12/28/2003
# Just another way of doing it.
#
# License agreement: Well...do whatever you want with it, but do
#                    it at your own risk.
# Disclaimer: There is no warranty whatsoever for this script and
#             I am not liable for any loss whatsoever in any case.
#
#--------------------------------------------------------------------------
#

my $storedResult = "";
my $noHitsCount = 0;
my $hitsCount = 0;
my $totalQuery = 0;

# Change the value of the following scalar to get the desired number
# of HSPs from hits (e.g. $numberHSPs = 5; to get 5 top HSPs).
my $HSP_count = 1;
my $first_query = 1;

print "Query\tQuery Length\tSubject\tSubject Length\tBit Score\tE-value\tPercent Identity\tAmino acid identity\tHSP length\n";
while (<>) {
	if (!(/^>/)){
		s/>/ /g;
	}
    
    if (/^Query=/) {
    	$totalQuery++;
    	if ($first_query) {
    		$first_query = 0;
    		$storedResult = $_;
    		next;
    	} else {        
        	$storedResult .= ">\n";
        	printHSPs ($storedResult, $HSP_count);
        	if ($storedResult =~ /^.*No hits found.*/m) {
            	$noHitsCount++;
        	} else {
            	$hitsCount++;
        	}
        $storedResult = "";
        $storedResult = $_;
        }   
    } else {
    	$storedResult .= $_;
    }
}
$storedResult .= ">\n";
printHSPs ($storedResult, $HSP_count);
if ($storedResult =~ /^.*No hits found.*/m) {
	$noHitsCount++;
} else {
	$hitsCount++;
}

print "\n\nTotal number of queries in the BLAST output file = $totalQuery \n";
print "Total number of queries with hits = $hitsCount\n";
print "Total number of queries with no hits = $noHitsCount\n";

exit;


#--------------------------------------------------------------------------
#Subroutine
#--------------------------------------------------------------------------
#
#
sub printHSPs {

    # Extracts and print annotations for HSPs contained in a blast result
    # for a single query. The number of HSPs to be printed is passed into
    # $numberToPrint from the main script.
    # Only collects info from top HSP from the subjects with multiple HSPs.
	my $arrayCount = 0;
    my ($oneResult, $numberToPrint) = @_;
    my ($query) = $oneResult =~ /^Query= (.*)$/m;
    my ($queryLength) = $oneResult =~ /\s+\((\d+) letters\)/;
    my @HSPs = ();
    my @lines = split /\n/, $oneResult;
    my $temp = "";
    my $seqFound = 0;
	my $collecting = 0;
	
	## print "$oneResult\n";
	## return;
	
    foreach my $line(@lines) {
    	$line .= "\n";
    	if ($line =~ /^>.*/) {   	
    		my $header = $line;
    		if ($collecting) {
    			push @HSPs, $temp;
    			$collecting = 0;
    			$temp = "";
    		}
    		if (!$collecting) {
    			$collecting = 1;
    			$temp .= $line;
    		}
    	} else {
    		$temp .= $line;
    	}
 
    }
    		
    my $i = @HSPs;
    my $j = 0;
    $numberToPrint = $i if ($i < $numberToPrint);
    if ($i == 0) {
        print "$query\t$queryLength\tNo hits found\n";
    } else {
        for ($j = 0; $j < $numberToPrint; $j++) {
            my ($HSP) = $HSPs[$j];
            my ($subjHeader) = $HSP =~ /^>(.*?)Length =/ms;
            $subjHeader =~ s/\n/ /g;
            $subjHeader =~ s/\s+/ /g;
            my ($subjLength) = $HSP =~ /^\s+Length = (\d+)/m;
            my ($bits) = $HSP =~ /^\s+Score =\s+(\d+\.?\d?\d?) bits/m;
            my ($eVal) = $HSP =~ /Expect\S*? = ([\d\.\+\-e]+)/;
            $eVal = "1$eVal" if $eVal =~ /^e/;
            my ($match, $total, $percent)
                = $HSP =~ /Identities = (\d+)\/(\d+) \((\d+)%\)/;
            print join ("\t", $query, $queryLength, $subjHeader, $subjLength,
                $bits, $eVal, $percent, $match, $total, "\n");
        }
    }    

}
#--------------------------------------------------------------------------

#!/usr/bin/perl -w
use strict;
use warnings;

#--------------------------------------------------------------------------
# print_atg_50.pl
#
#
#
#
# Usage: ./print_atg_50.pl input_fasta_file > output_file
#
# Written by Joe Win, Kamoun lab, OSU-OARDC
#
#--------------------------------------------------------------------------



#
# hash for translating DNA
#
my %DNAtoAA = ('GCT' => 'A', 'GCC' => 'A', 'GCA' => 'A', 'GCG' => 'A', 'TGT' => 'C',
	       'TGC' => 'C', 'GAT' => 'D', 'GAC' => 'D', 'GAA' => 'E', 'GAG' => 'E',
	       'TTT' => 'F', 'TTC' => 'F', 'GGT' => 'G', 'GGC' => 'G', 'GGA' => 'G',
	       'GGG' => 'G', 'CAT' => 'H', 'CAC' => 'H', 'ATT' => 'I', 'ATC' => 'I',
	       'ATA' => 'I', 'AAA' => 'K', 'AAG' => 'K', 'TTG' => 'L', 'TTA' => 'L',
	       'CTT' => 'L', 'CTC' => 'L', 'CTA' => 'L', 'CTG' => 'L', 'ATG' => 'M',
	       'AAT' => 'N', 'AAC' => 'N', 'CCT' => 'P', 'CCC' => 'P', 'CCA' => 'P',
	       'CCG' => 'P', 'CAA' => 'Q', 'CAG' => 'Q', 'CGT' => 'R', 'CGC' => 'R',
	       'CGA' => 'R', 'CGG' => 'R', 'AGA' => 'R', 'AGG' => 'R', 'TCT' => 'S',
	       'TCC' => 'S', 'TCA' => 'S', 'TCG' => 'S', 'AGT' => 'S', 'AGC' => 'S',
	       'ACT' => 'T', 'ACC' => 'T', 'ACA' => 'T', 'ACG' => 'T', 'GTT' => 'V',
	       'GTC' => 'V', 'GTA' => 'V', 'GTG' => 'V', 'TGG' => 'W', 'TAT' => 'Y',
	       'TAC' => 'Y', 'TAA' => 'Z', 'TAG' => 'Z', 'TGA' => 'Z',
	       'ACN' => 'T', 'CCN' => 'P', 'CGN' => 'R', 'CTN' => 'L',
		   'GCN' => 'A', 'GGN' => 'G', 'GTN' => 'V', 'TCN' => 'S');


my $thisLine = "";
my $oneLongSeq = "";
my $thisSeqIndex = 0;
my $inSequence = 0;
my $seqComplete = 0;
my $totalSeqCount = 0;
my $tempSeq = "";
my @sequences;
my $input=shift;
my $direction = shift;
open(INP, $input) || die "Cannot open file \"$input\"\n\n";

while (<INP>) {
    chomp;
    $thisLine = $_;
    if ($thisLine =~ /^>/) {
        if ($inSequence) {
            $inSequence = 0;
            $seqComplete = 1;
        } else {
            $inSequence = 1;
            $seqComplete = 0;
        }
        $thisLine .= "\n";
    } else {
        $inSequence = 1;
    }
    
    if ($inSequence) {
        $tempSeq .= "$thisLine";
    }
    
    if ($seqComplete) {
        $tempSeq =~ /^(>.*)\n/;
		my $header = $1;
		print_atg_50 ($header,$tempSeq, 1, $direction);
        $tempSeq = "$thisLine";
        $seqComplete = 0;
        $inSequence = 0;
        $totalSeqCount++;
    }
}
$tempSeq =~ /^(>.*)\n/;
my $header = $1;
print_atg_50 ($header,$tempSeq, 1);
$totalSeqCount++;

exit;


#--------------------------------------------------------------------------
# Subroutines
#--------------------------------------------------------------------------

sub print_atg_50 {
	my ($this_header, $thisSeq, $frame, $direction) = @_;
	$thisSeq =~ s/>.*?\n//;
	$thisSeq =~ tr/[actg]/[ACTG]/;
	while ($thisSeq =~ /[ATCG]*?(ATG\w+?$)/) {
		my $this_frame = $1;
		my $seq_length = length ($this_frame);
		if ($seq_length < 210) {		
			last;
		}
		my $peptide = translate_from_atg($this_frame);
		if (length($peptide) >= 50) {
			print "$this_header","_","$direction","$frame","\n";
			print "$peptide\n";
			$thisSeq = substr($this_frame, 3);
			$frame++;
		} else {
			$thisSeq = substr($this_frame, 3);
		}
	}
	return;
}

#--------------------------------------------------------------------------

sub translate_from_atg {
	my $this_seq = shift;
	$this_seq =~ tr/[a-z]/[A-Z]/;
	my $pept;
	for (my $y = 0; $y < (length($this_seq) - 3); $y += 3) {
		if (!defined $DNAtoAA{substr($this_seq, $y, 3)}) {
			$pept .= "X";
		} else {
			$pept .= $DNAtoAA{substr($this_seq, $y, 3)};
			if ($DNAtoAA{substr($this_seq, $y, 3)} eq "Z") {last}
		}
	}
	return $pept;
}

#--------------------------------------------------------------------------

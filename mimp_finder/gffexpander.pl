#!/usr/bin/perl -w
#
use strict;
use warnings;
#
#
#-------------------------------------------------------------------------
# gffexpander.pl
#-------------------------------------------------------------------------
# This script will accept features in a gff file and expand the region
# of the gff features by Xbp either upstream, downstream of both.
# This can be used with bedtools intersect to identify whether the newly 
# expanded features eg. promotors overlap nearby features of interest 
# eg. genes

my $usage = "gffexpander.pl <+,- or +-> <distanceto_expand(bp)> <feature_file.gff>";
#-------------------------------------------------------------------------
# 1. Initiate variables
#-------------------------------------------------------------------------
# my $seqName = "";
# my @seqNames = ();
# my $dnaSeq = "";
# my @dnaSeqs = ();
# my $total = 0;
# my $tempSeq=();
# my $thisLine=();
# my $inSequence = 0;
# my $seqComplete = 0;


# Set whether extending upstream of the feature, downstream of the feature or both
my $UpDown = shift;
unless ($UpDown =~ m/\+|\-/) {die "$usage"};
# Set the no. bp to extend the feature by	
my $distance = shift;
unless ($distance =~ m/\d+/) {die "$usage"};
# Open input file
my $gffFile = shift;
# chomp $fastaFile;


# Fasta Output
# my $outFile = shift;
# chomp $outFile;
# .gff Output
# my $outGff = shift;
# chomp $outGff;





#-------------------------------------------------------------------------
# 2. Open input &  collect sequences in two parallel arrays:
#	one for names and one for aa sequences.
#-------------------------------------------------------------------------

open (GFF_FILE, "$gffFile ") || die "Cannot open file \"$gffFile\"\n\n";

#my $flag=0;

while (<GFF_FILE>) {
   	chomp;
   	my $thisLine = $_;
   	my @gffFeatureIn = split("\t", $thisLine);
   
   	my $col1 = shift @gffFeatureIn;			# Sequence id
	my $col2 = shift @gffFeatureIn;			# Source
	my $col3 = shift @gffFeatureIn;			# Type
	my $col4 = shift @gffFeatureIn;			# Start
	my $col5 = shift @gffFeatureIn;			# End
	my $col6 = shift @gffFeatureIn;			# Score
	my $col7 = shift @gffFeatureIn;			# Strand
	my $col8 = shift @gffFeatureIn;			# Phase
	my $col9 = "@gffFeatureIn";				# Attribute
	
    ($col4, $col5) = mod_gff($col4, $col5, $col7, $UpDown, $distance);			# $mimpStart, $mimpEnd, $strand
	print join ("\t", $col1, $col2, $col3, $col4, $col5, $col6, $col7, $col8, $col9) . "\n";
}		

close (GFF_FILE);
    
exit;
#-------------------------------------------------------------------------
# Sub 1. Modify .gff features.
#-------------------------------------------------------------------------

# sub print_gff {
# 	my ($mimpStart, $mimpEnd, $strand, $UpDown, $Dist) = @_;
# 	if $strand eq '+' {
# 		extendX($mimpStart, $mimpEnd, $UpDown, $Dist)
# 	}	
# 	
# 	if $UpDown ~= m/\+/ { 
# }

sub mod_gff {
	my ($mimpStart, $mimpEnd, $strand, $UpDown, $distance) = @_;
    my $upstream = 'no'; 
    my $downstream = 'no';
    if ($UpDown =~ m/\-/) { $upstream = 'yes'; }
    if ($UpDown =~ m/\+/) { $downstream = 'yes'; }
#    $mimpStart = 0;
    if ($strand eq '+') {
    	if ($downstream eq 'yes') {
    		$mimpEnd += $distance;
    	}
    	if ($upstream eq 'yes') {
    		$mimpStart -= $distance;
    	}
    } elsif ($strand eq '-') {
    	if ($downstream eq 'yes') {
    		$mimpStart -= $distance;
    	}
    	if ($upstream eq 'yes') {
    		$mimpEnd += $distance;
    	}
    }
    if ($mimpStart <= 0) {
    	$mimpStart = 0;
    }
	return ($mimpStart, $mimpEnd);
}
    	
# 	if ($thisLine =~ /^>/ && $flag==0) {
# 		#print "START LINE DETECTED $thisLine \n";
# 		#$thisLine .= "\n";	
# 		push (@seqNames, $thisLine);
# 		$flag=1;
#         	}
# 	elsif ( $thisLine =~ /^>/ && $flag==1){
# 		# print "START LINE DETECTED $thisLine \n";
# 		 push (@seqNames, $thisLine);
# 		 push (@dnaSeqs,$tempSeq);
# 		 $tempSeq=();
# 		}
# 	else {
#         	$tempSeq .= "$thisLine";
#     	}
# 	
# }
# #print "PUSHING FINAL LINE\n";
# push (@dnaSeqs,$tempSeq);
# close FASTA_FILE;
# 
# print "SEQUENCES IN NAME ARRAY  ".scalar(@seqNames)."\n";
# print "SEQUENCES IN SEQS ARRAY  ".scalar(@seqNames)."\n";

#-------------------------------------------------------------------------
# 3. Open fasta and gff outfiles
#-------------------------------------------------------------------------

# open (OUT, ">$outFile") || die "Cannot open file \"$outFile\"\n\n";
# print OUT "Following FASTA files contain the mimp motif...\n";
# 
# open (GFF, ">$outGff") || die "Cannot open file \"$outGff\"\n\n";

#-------------------------------------------------------------------------
# 4. Work through arrays identifying mimps
#-------------------------------------------------------------------------
# my $subSeq;
# my $mimpCount = 0;
# my $i = 0;
# $total = @seqNames;

# 
# 
# for ($i = 0; $i < $total; $i++) {
# #for ($i = 140; $i < 141; $i++) {
#     #print "Working on $seqNames[$i] \n";
#     $seqName = $seqNames[$i];
#     $dnaSeq = $dnaSeqs[$i];
#   
# 	while ($dnaSeq =~/CAGTGGG..GCAA[TA]AA/g ){
# 		my $mimp_pos = pos($dnaSeq) ;
# 		print "FOUND MIMP on $seqName at $mimp_pos\n";
#          	$mimpCount=$mimpCount+1;;
# 		print OUT "$seqName --mimp starts at $mimp_pos\.\n";
#         	print OUT substr($dnaSeq, ($mimp_pos-16), 80), "\n";
# 		my $mimpStart = $mimp_pos-15;
# 		my $mimpEnd = $mimp_pos;
# 		my $strand = "+";
#    	    print_gff($seqName, $mimpStart, $mimpEnd, $strand, $mimpCount);
# 	}
# 	while ($dnaSeq =~/TT[TA]TTGC..CCCACTG/g ){
# 		my $mimp_pos = pos($dnaSeq) ;
# 		print "FOUND MIMP on $seqName at $mimp_pos\n";
# 		$mimpCount=$mimpCount+1;;
# 		print OUT "$seqName --mimp starts at $mimp_pos\.\n";
# 			print OUT substr($dnaSeq, ($mimp_pos-16), 80), "\n";
# 		my $mimpStart = $mimp_pos-15;
# 		my $mimpEnd = $mimp_pos;
# 		my $strand = "-";
#       	print_gff($seqName, $mimpStart, $mimpEnd, $strand, $mimpCount);
#     }
# 
#     
# }
# 
# print OUT "There are $mimpCount sequences that contain the consensus mimp motif\n";
# print "There are $mimpCount sequences that contain the consensus mimp motif\n";
# close (OUT);
# close (GFF);
# 
# exit;
# 
# 
# #-------------------------------------------------------------------------
# # Sub 1. Print hit to gff.
# #-------------------------------------------------------------------------
# 
# sub print_gff {
# 	my ($seqName, $mimpStart, $mimpEnd, $strand, $mimpCount) = @_;
# 	$seqName = substr $seqName, 1;			# Removes ">" from name
# 
# 	my $col1 = "$seqName";					# Sequence id
# 	my $col2 = "mimp_finder.pl";			# Source
# 	my $col3 = "MIMP_motif";				# Type
# 	my $col4 = "$mimpStart";				# Start
# 	my $col5 = "$mimpEnd";					# End
# 	my $col6 = ".";							# Score
# 	my $col7 = "$strand";					# Strand
# 	my $col8 = ".";							# Phase
# 	my $col9 = "ID=\"MIMP_$mimpCount\"";	# Attributes
# 
# 	print GFF join ("\t", $col1, $col2, $col3, $col4, $col5, $col6, $col7, $col8, $col9) . "\n";
# }
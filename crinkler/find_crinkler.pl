#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

my $infile;
my $motif_name;

my $seqio_obj;
my $nuc_seq_obj;
my $motif_start;
my $motif_end;
my $motif;
my $motif_pos;
my $this_seq;
my @sub_return = '2';
my %outhash;
#my $usage="find_crinkler.pl <gene_models.fa> > crinkler_hit.fa";
my $usage="find_crinkler.pl <gene_models.fa> [query_motif1] [query_motif2] [query_motifx]";


# Run this search for multiple motifs before identifying loci that carry all of these motifs using :
# cat findmotif_RXLR.fa findmotif_LVHLQ.fa | grep '>' | cut -f1 | sort | uniq -d | less


$infile = shift or die("Usage: $usage $!");
$seqio_obj = Bio::SeqIO->new(-file=>"$infile", -format => "fasta" -alphabet => 'dna' );

#$motif="DKPVY";
#my @ao_motif = "DKPVY"; 
my @ao_motif = @ARGV;
print "@ao_motif\n";

# for (@ao_motif) {
# 	my $outhash->{ "$_" } = undef;
# }
$outhash{@ao_motif} = '';

#print "$_\n" for keys %outhash;


# for (@ao_motif) {
# 	$motif = $_;
# #	print "$_\n";
# 	$motif =~ tr /x/X/;
# 	my $motif_filehandle = \*"$motif"; 
# #	print "$motif_filehandle\n";
# #	open (OUTFILE, ">outfile.txt") or die "could not open file\n"; 
# 	my $out_name = "findmotif_"."$motif".".fa";
# 	open ($motif_filehandle, ">$out_name") or die "could not open file\n"; 
# }



while ($nuc_seq_obj = $seqio_obj->next_seq){
	my $id = $nuc_seq_obj->id;
	my $prot_seq_oj = $nuc_seq_obj->translate(-orf => 'longest', -start => "atg" );
	my $seq = $prot_seq_oj->seq;
#	print "$motif\n";	
#	print "$seq\n";
# 	@sub_return = motif_search ($motif, $seq);
# 	my $motif_start = shift @sub_return;
# 	if ($motif_start == '') {exit; next;}
# 	my $motif_end = shift @sub_return;
# 	print "\nmotif found\n";
# 	print "motif in: $id\n";
# 	print "motif start: $motif_start\n";
# 	print "motif end: $motif_end\n";
#	print_gff ($seq_obj, $motif, $motif_start, $motif_end);


	for (@ao_motif) {
		$motif = $_;
#		motif_search ($motif, $seq, $nuc_seq_obj, \%outhash);
		%outhash = motif_search ($motif, $seq, $nuc_seq_obj, %outhash);
	}
	
}

for (@ao_motif) {
	$motif = $_;
	my $outfile_name = "findmotif_"."$motif".".fa";
	open (OUTFILE, ">$outfile_name");
	print OUTFILE "$outhash{$motif}";
}
		
# 	print OUT_FILE "\nmotif found\n";
# 	print OUT_FILE "motif in: $id\n";
# 	print OUT_FILE "motif start: $motif_start\n";
# 	print OUT_FILE "motif end: $motif_end\n";
#	exit;
#	}
#}
# 	
# 	if (shift @_ = 1 ) {
# 		motif_search (LYLAK, $seq_obj)
# 		if (shift @_ = 1 ) { 
# 			motif_search (HVLVVVP, $seq_obj);
# 		}
# #	}

sub motif_search {
	my $motif = shift @_;
	my $seq = shift @_;
	my $nuc_seq_obj = shift @_;
	my %outhash = @_;
#	my $seq_obj = shift @_;
#	my $seq = $seq_obj->translate(-orf => 1, -start => "atg" );
#	my $seq = $seq_obj->seq;
	$motif =~ tr /x/\./;
#	print "searching for motif $motif\n";
# 	print "$motif\n";
# 	print "$seq\n"; 
	if ($seq =~ /$motif/){
		my $result = index($seq, $&);
		$motif_start = "$result" * '3';
		my $motif_lgth = length ($motif);
		$motif_end = ("$motif_start" + "$motif_lgth") * 3;
#		return ($motif_start, $motif_end);
#		print_fasta ($nuc_seq_obj, $motif, $motif_start, $motif_end);
		%outhash = build_outhash ($nuc_seq_obj, $motif, $motif_start, $motif_end, %outhash);
#		print_gff ($nuc_seq_obj, $motif, $motif_start, $motif_end);
	return (%outhash);
	}
	else { return (%outhash);}
# 	return ('');
# 	}
# 	else { return ('', '');}
}

sub build_outhash {
	my $nuc_seq_obj = shift @_;
	my $motif = shift @_;
	my $motif_start = shift @_;
	my $motif_end = shift @_;
	my %outhash = @_;
	$motif =~ tr /./x/;
	my $id = $nuc_seq_obj->id;
	my $seq = $nuc_seq_obj->seq;
	#print "I got here, finding motif : $motif\n";
#	print "handle = $motif_filehandle\n";
	my $outstring = ">"."$id\t-feature_at: $motif_start\n$seq\n";
#	print "$outhash{$motif}\n";
#	print (keys %outhash, "\n");
#	print "$_\n" for keys %outhash;
#	print "$motif\n";
	$outhash{"$motif"} .= $outstring;
	return (%outhash);
}


# sub print_fasta {
# 	my $nuc_seq_obj = shift @_;
# 	my $motif = shift @_;
# 	my $motif_start = shift @_;
# 	my $motif_end = shift @_;
# 	$motif =~ tr /./X/;
# 	my $motif_filehandle = $motif;
# 	my $id = $nuc_seq_obj->id;
# 	my $seq = $nuc_seq_obj->seq;
# 	print "I got here\n";
# 	print "handle = $motif_filehandle\n";
# #	print OUTFILE "$id\n$seq\n";
# 	print $motif_filehandle ">"."$id\t-feature_at: $motif_start\n$seq\n";
# }

# sub print_gff {
# 	my $nuc_seq_obj = shift @_;
# 	my $motif = shift @_;
# 	my $motif_start = shift @_;
# 	my $motif_end = shift @_;
# 	
 

exit;
# 		$crn_name = $seq_obj -> name()
# 		$crn_pos = 
# 		$crn_seq = 
# 		print <OUT_FASTA> "$crn_name\n"
# 		print <OUT_FASTA> "$crn_seq\n"
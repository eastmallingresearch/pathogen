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
my $usage="find_crinkler.pl <gene_models.fa> [query_motif1] [query_motif2] [query_motifx]";

# Run this search for multiple motifs before identifying loci that carry all of these motifs using :
# cat findmotif_RXLR.fa findmotif_LVHLQ.fa | grep '>' | cut -f1 | sort | uniq -d | less

$infile = shift or die("Usage: $usage $!");
$seqio_obj = Bio::SeqIO->new(-file=>"$infile", -format => "fasta" -alphabet => 'dna' );

my @ao_motif = @ARGV;
print "@ao_motif\n";

$outhash{@ao_motif} = '';

while ($nuc_seq_obj = $seqio_obj->next_seq){
	my $id = $nuc_seq_obj->id;
	my $prot_seq_oj = $nuc_seq_obj->translate(-orf => 'longest', -start => "atg" );
	my $seq = $prot_seq_oj->seq;
	for (@ao_motif) {
		$motif = $_;
		%outhash = motif_search ($motif, $seq, $nuc_seq_obj, %outhash);
	}
}

for (@ao_motif) {
	$motif = $_;
	my $outfile_name = "findmotif_"."$motif".".fa";
	open (OUTFILE, ">$outfile_name");
	print OUTFILE "$outhash{$motif}";
}

exit;

#-------------------------------------------------------

sub motif_search {
	my $motif = shift @_;
	my $seq = shift @_;
	my $nuc_seq_obj = shift @_;
	my %outhash = @_;
	$motif =~ tr /x/\./;
	if ($seq =~ /$motif/){
		my $result = index($seq, $&);
		$motif_start = "$result" * '3';
		my $motif_lgth = length ($motif);
		$motif_end = ("$motif_start" + "$motif_lgth") * 3;
		%outhash = build_outhash ($nuc_seq_obj, $motif, $motif_start, $motif_end, %outhash);
	return (%outhash);
	}
	else { return (%outhash);}
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
	my $outstring = ">"."$id\t-feature_at: $motif_start\n$seq\n";
	$outhash{"$motif"} .= $outstring;
	return (%outhash);
}

# sub print_gff {
# 	my $nuc_seq_obj = shift @_;
# 	my $motif = shift @_;
# 	my $motif_start = shift @_;
# 	my $motif_end = shift @_;
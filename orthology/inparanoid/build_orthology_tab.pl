#!/usr/bin/perl
use strict;
use warnings;

my $usage = "build_orthology_tab.pl <gene_list.txt> <sqltable.txt>";
my $gene_file = shift or die $usage;
my %hashofgenes;
my $hit_lines = '';
my $search_seq;
my @ao_hit_line;
my $hash_column = '0';
my @ao_inputs = '';

# build a hash table of all the genes in the gene list file.
# This will be populated with the gene associations between
# each gene according to the sqltable files.

while (@ARGV){
	my $inparanoid_outfile = shift;
	open GENEFILE, $gene_file;
	$hash_column++;
	push (@ao_inputs, $inparanoid_outfile);
	build_gene_hash ($inparanoid_outfile, $hash_column);
}

print join ("\t", @ao_inputs), "\n";
for my $key ( keys %hashofgenes ) {
   print "$key\t", join("\t", @{$hashofgenes{$key}}), "\n";
}

exit;

#------------------------------------------------------------
#
#------------------------------------------------------------
	
sub build_gene_hash {
	my ($inparanoid_outfile, $hash_column) = @_;
	while (<GENEFILE>){
		open SQLFILE1, $inparanoid_outfile;
		my $hit_orthogroups = '';
		my $cur_gene =  "$_";
		chomp $cur_gene;
		$cur_gene =~ s/^\s+|\s+$//g;
		while (<SQLFILE1>) {
			my $cur_line = "$_";
			$cur_gene =~ m/\|/;
			$search_seq = "$`" . "." . "$'";
#			print "$search_seq\n";
			if ($cur_line =~ m/$search_seq\t/) { 
#			if ($cur_line =~ m/$cur_gene\t/) {
#				print "$search_seq *_*\t";
				$hit_lines = $`;
#				print "$hit_lines\n";
				@ao_hit_line = split ("\t", $hit_lines);
				$hit_orthogroups .= "$ao_hit_line[0]" . ",";
#				print "$cur_gene\n$search_seq\n$cur_line\n$hit_lines\n@ao_hit_line\n";
#				exit;
				}
		}
		if ($hit_orthogroups eq '') {$hit_orthogroups = '-,'};	
		push @{ $hashofgenes{$cur_gene} }, $hit_orthogroups;
	}
}


	
	
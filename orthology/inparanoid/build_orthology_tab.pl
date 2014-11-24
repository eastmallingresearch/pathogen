#!/usr/bin/perl
use strict;
use warnings;

my $usage = "build_orthology_tab.pl <gene_list.txt> <sqltable.txt>";
my $gene_file = shift or die $usage;
#my $sqltab1 = shift or die $usage;
#open GENEFILE, $gene_file;
my %hashofgenes;
my $hit_lines = '';
my $search_seq;
my @ao_hit_line;
my $hash_column = '0';


# build a hash table of all the genes in the gene list file.
# This will be populated with the gene associations between
# each gene according to the sqltable files.

while (@ARGV){
	my $inparanoid_outfile = shift;
	open GENEFILE, $gene_file;
	$hash_column++;
	print "cycle $hash_column\n";
 	print "$inparanoid_outfile\n";
	build_gene_hash ($inparanoid_outfile, $hash_column);
}

for my $key ( keys %hashofgenes ) {
   print "$key\t", join("\t", @{$hashofgenes{$key}}), "\n";
}

exit;






	
sub build_gene_hash {
	my ($inparanoid_outfile, $hash_column) = @_;
# 	print $inparanoid_outfile;
# 	exit;
	while (<GENEFILE>){
		open SQLFILE1, $inparanoid_outfile;
		my $hit_orthogroups = '';
		my $cur_gene =  "$_";
		chomp $cur_gene;
		$cur_gene =~ s/^\s+|\s+$//g;
		while (<SQLFILE1>) {
			my $cur_line = "$_";
			$cur_gene =~ m/\|/;
			$search_seq = $';
			if ($cur_line =~ m/$search_seq/) { 
				$hit_lines = $`;
#				print "$hit_lines\t$inparanoid_outfile\n";
				@ao_hit_line = split ("\t", $hit_lines);
				$hit_orthogroups .= $ao_hit_line[1];
				}
		}
		if ($hit_orthogroups eq '') {$hit_orthogroups = '-'};	
		push @{ $hashofgenes{$cur_gene} }, $hit_orthogroups;
	#	%hashofgenes = ($cur_gene => "$hit_lines");
	#	print "$cur_gene\n" for keys %hashofgenes;
	#	print "$cur_gene\t@hashofgenes{$cur_gene}\n";
	#	exit;
#	close SQLFILE1;
	}
}


#print "%hashofgenes";

	
	
#!/usr/bin/perl
use strict;
use warnings;

# blast2gff.pl parses outputs from blast_pipe.sh to .gff files.

my $usage = "blast2gff.pl <feature_name (ie. RxLR_gene)> <blast_homolgy_file.txt> > <blast_homology.gff>";

my $feature_name = shift or die $usage;
my $infile = shift or die $usage;


my @ao_line;
my $iteration = "";

my $hit_contig = "";
my $hit_start = "";

my $hit_end = "";
my $per_id = "";
my $hit_strand = "";
my $hit_name = "";

my $col1 = "";
my $col2 = "BLAST_homolog";
my $col3 = "$feature_name";
my $col4 = "";
my $col5 = "";
my $col6 = "";
my $col7 = "";
my $col8 = ".";
my $col9 = "";

open (INFILE, "$infile") or die "\nERROR: $infile could not be opened\n";
 
while (my $line = <INFILE>) {
	@ao_line = split ('\t', $line);
	if ($ao_line[0] eq "ID") { 
		foreach (@ao_line) { 
			if ($hit_end ne "") {last} # checks if values are already defined for the variables below.
			elsif ($_ =~ m/^Hit$/) {$hit_contig = $iteration;}
			elsif ($_ =~ m/Per_ID/) {$per_id = $iteration;}
			elsif ($_ =~ m/Hit_strand/) {$hit_strand = $iteration;}
			elsif ($_ =~ m/Hit_start/) {$hit_start = $iteration;}
			elsif ($_ =~ m/Hit_end/) {$hit_end = $iteration;}
			$iteration ++;
			}				

	} else {
		$col1 = $ao_line[$hit_contig];
		$col4 = $ao_line[$hit_start] or next;
		$col5 = $ao_line[$hit_end];
		$col6 = $ao_line[$per_id];
		$col7 = $ao_line[$hit_strand];
		if ($col7 eq '-1') {$col7 = '-';} else {$col7 = '+';} 
		$col9 = "NAME=$ao_line[0]";
	print "$col1\t$col2\t$col3\t$col4\t$col5\t$col6\t$col7\t$col8\t$col9\n";
	}
}

exit;

#!/usr/bin/perl
#analyse orthology tab
use strict;
use warnings;

my useage = analyse_orthology_tab.pl <orthology_table.csv>

my $infile = shift;
my %orthology_hash = build_hash ($infile);

for my $key ( keys %orthology_hash ) {
   print "$key\t", join("\t", @{$orthology_hash{$key}}), "\n";
}




#-----------------------------------------------------
#		subroutines
#-----------------------------------------------------
#
#	Building the initial hash
#

sub build_hash {
	my ($infile) = @_;
	open (INFILE, $)infile; 
	my %hash;
	while (<INFILE>) {
		@cur_line = split ($_, "\t");
		$line_key = shift @cur_line;
		while (@cur_line) {
			push @{ $hash{$line_key} }, $_;
		}
	}
	return (%hash)
}

#-----------------------------------------------------
#	Querying for a gene

#-----------------------------------------------------
#	Finding analagous genes
	


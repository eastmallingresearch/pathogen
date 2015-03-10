#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

# blast2gff.pl parses outputs from blast_pipe.sh to .gff files.

my $usage = "blast2gff.pl <feature_name (ie. RxLR_gene)> <blast_homolgy_file.txt> > <blast_homology.gff3>";

my $feature_name = shift or die $usage;
my $infile = shift or die $usage;


my @ao_line;
my $iteration = 0;
# 
# my $hit_contig = "";
# my $hit_start = "";
# 
# my $hit_end = "";
# my $per_id = "";
# my $hit_strand = "";
# my $hit_name = "";
my @hit_contig;
my @hit_start;
my @hit_end;
my @per_id;
my @hit_strand;
my @hit_name;

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
#		my @hit_contig, @hit_strand, @hit_start, @hit_end = assign_headers(@ao_line);
#		print "@header_pos\n";
#		print split (";", @header_pos) . "\n";
#		my $hit_contig = split (";", @header_pos);
#@hit_strand, @hit_start, @hit_end) = 
#		print "@hit_contig\n\n";
		foreach (@ao_line) {
#		print "$ao_line[$iteration]\n";
		if ($_ =~ m/^Hit$/) {push @hit_contig, "$iteration";}
		elsif ($_ =~ m/^Hit$/) {push @hit_contig, "$iteration";}
		elsif ($_ =~ m/Per_ID/) {push @per_id, "$iteration";}
		elsif ($_ =~ m/Hit_strand/) {push @hit_strand, "$iteration";}
		elsif ($_ =~ m/Hit_start/) {push @hit_start, "$iteration";}
		elsif ($_ =~ m/Hit_end/) {push @hit_end, "$iteration";}
		$iteration ++;
		}



#		print "\n\n@hit_contig\n@hit_strand\n@hit_start\n@hit_end\n\n"
	} else {
		my $i = 0;
		for (@hit_contig) { 
			$col1 = $ao_line[$hit_contig[$i]] or next;
			$col4 = $ao_line[$hit_start[$i]];
			$col5 = $ao_line[$hit_end[$i]];
			$col6 = $ao_line[$per_id[$i]];
			$col7 = $ao_line[$hit_strand[$i]];
			if ($col7 eq '-1') {$col7 = '-';} else {$col7 = '+';} 
			$i++;
			$col9 = "\"ID=" . "$ao_line[0]" . "_BlastHit_$i" . "\";";
			print "$col1\t$col2\t$col3\t$col4\t$col5\t$col6\t$col7\t$col8\t$col9\n";
		}
	}
}

exit;


# sub assign_headers {
# 	my @ao_line = @_;
# 	my $iteration = 0;
# 	my @hit_contig;
# 	my @hit_start;
# 	my @hit_end;
# 	my @per_id;
# 	my @hit_strand;
# 	my @hit_name;
# 
# 	foreach (@ao_line) {
# #		if ($hit_end ne "") {last} # checks if values are already defined for the variables below.
# #		elsif ($_ =~ m/^Hit$/) {$hit_contig = $iteration;}
# # 		elsif ($_ =~ m/^Hit$/) {$hit_contig = $iteration;}
# # 		elsif ($_ =~ m/Per_ID/) {$per_id = $iteration;}
# # 		elsif ($_ =~ m/Hit_strand/) {$hit_strand = $iteration;}
# # 		elsif ($_ =~ m/Hit_start/) {$hit_start = $iteration;}
# # 		elsif ($_ =~ m/Hit_end/) {$hit_end = $iteration;}
# 		print "$ao_line[$iteration]\n";
# 		if ($_ =~ m/^Hit$/) {push @hit_contig, "$iteration"; print "\tHit\n"; print "@hit_contig\n"}
# 		elsif ($_ =~ m/^Hit$/) {push @hit_contig, "$iteration";}
# 		elsif ($_ =~ m/Per_ID/) {push @per_id, "$iteration";}
# 		elsif ($_ =~ m/Hit_strand/) {push @hit_strand, "$iteration";}
# 		elsif ($_ =~ m/Hit_start/) {push @hit_start, "$iteration";}
# 		elsif ($_ =~ m/Hit_end/) {push @hit_end, "$iteration";}
# 		$iteration ++;
# 		}
# 		
# 	return (\@hit_contig, \@hit_strand, \@hit_start, \@hit_end);
# }



#!/usr/bin/perl
#analyse orthology tab
use strict;
use warnings;

my $usage = "analyse_orthology_tab.pl <orthology_table.csv> [optional: -file list_of_genes.txt -deep]/n";


my $in_tab = shift or die $usage;
my $manual_input = 'Yes';
my $deep_search = 'No';
my $gene_file;
foreach (@ARGV) {
	my $cur_element = shift @ARGV;
	if ($cur_element eq '-file') {
		$manual_input = 'No'; 
		$gene_file = shift @ARGV;
	} elsif ($cur_element eq '-deep') {
		$deep_search = 'Yes';
	}
}
	
build_hash ($in_tab);
my %orthology_hash = build_hash ($in_tab);

if ($manual_input eq 'Yes') {
	my $search_again = 'y';
	while ($search_again eq 'y') {
		$search_again = manual_search ($deep_search, %orthology_hash);
	}
} elsif ($manual_input eq 'No') {
	from_file ($gene_file, $deep_search, %orthology_hash);
}
	

# for my $key ( keys %orthology_hash ) {
#    print "$key\t", join("\t", @{$orthology_hash{$key}}), "\n";
# }

exit;



#-----------------------------------------------------
#		subroutines
#-----------------------------------------------------
#
#	Building the initial hash
#

sub build_hash {
	my ($infile) = @_;
	open (INFILE, $infile); 
	my %orthology_hash;
	while (<INFILE>) {
 		my $cur_line = $_;
 		chomp $cur_line;
  		my @cur_line = split ("\t", $cur_line);
  		my $line_key = shift @cur_line;
 		foreach (@cur_line) {
			push @{ $orthology_hash{$line_key} }, $_;
 		}
 	}
 	return (%orthology_hash);
 }

#-----------------------------------------------------
#	Querying for a gene
sub manual_search {
	my ($deep_search) = shift @_;
	my (%orthology_hash) = @_;
		print "Please enter the name of the gene you wish to search for\n";
	my $search_name = <STDIN>;
	chomp $search_name;
	print "Would you like to print search results to an outfile?\ty\tn\n";
	my $print_switch = <STDIN>;
	chomp $print_switch;
	unless ($print_switch eq 'y'||'n') {print "Error: Answer y or n. Not printing results for now.\n";}
	print "\nLooking for gene:\t";
	print "$search_name\n\n";
	my %out_hash = ortholog_search ($search_name, $deep_search, %orthology_hash);
	print "Orthology groups are:\t";
	print join("\t",$search_name, @{$out_hash{$search_name}}), "\n\n";
	print "Members of this ortholog group are:\n";
	for my $key ( keys %out_hash ) {
    	print join("\t",$key, @{$out_hash{$key}}), "\n";
	}	
	if ($print_switch eq 'y') { sub_print ($search_name, %out_hash)}
	print "would you like to search again?\ty\tn\n";
	my $search_again = <STDIN>;
	chomp $search_again;
	return $search_again;
}


#-----------------------------------------------------
# collect a list of genes to search for from a file.
sub from_file {
	my ($gene_file) = shift @_;
	my ($deep_search) = shift @_;
	my (%orthology_hash) = @_;
	open INGENES, $gene_file;
		while (<INGENES>) {
			my $search_name = $_;
			chomp $search_name;
			my %out_hash = ortholog_search ($search_name, $deep_search, %orthology_hash);
			sub_print ($search_name, %out_hash)
		}
}


	
#-----------------------------------------------------
# search for orthologous genes to the query

sub ortholog_search {
	my ($search_name) = shift @_;
	my ($deep_search) = shift @_;
	my (%orthology_hash) = @_;
	my %out_hash;
	my @ortholog_groups = @{$orthology_hash{$search_name}} or print "\nError: Can not find $search_name in hash\n";
	for my $key ( keys %orthology_hash ) {
		my @cur_line = @{$orthology_hash{$key}};
		my @remaining_elements = @cur_line;
		foreach (@ortholog_groups) {
			my $this_ortholog = $_;
			if ($this_ortholog ne '-' && $this_ortholog eq shift @remaining_elements) {
				if (exists ($out_hash{$key})) {
				} else {
					push @{ $out_hash{$key} }, @cur_line;
				}
				last;
			} 
		}
	}
	if ($deep_search eq 'Yes') {
	#This does a second round of searching to identify all the orthologs listed to the identified orthologs.
		for my $search_name ( keys %out_hash ) {
			my @ortholog_groups = @{$orthology_hash{$search_name}} or print "\nError: Can not find $search_name in hash\n";
			for my $key ( keys %orthology_hash ) {
				my @cur_line = @{$orthology_hash{$key}};
				my @remaining_elements = @cur_line;
				foreach (@ortholog_groups) {
					my $this_ortholog = $_;
					if ($this_ortholog ne '-' && $this_ortholog eq shift @remaining_elements) {
						if (exists ($out_hash{$key})) {
						} else {
							push @{ $out_hash{$key} }, @cur_line;
						}
						last;
					} 
				}
			}
		}
	}
	return %out_hash;
}

#-----------------------------------------------------
# search for orthologs of the orthologs

sub deep_search {
	my ($search_name) = shift @_;
	my (%orthology_hash) = shift @_;
	my (%out_hash) = shift @_;
	my @ortholog_groups = @{$orthology_hash{$search_name}} or print "\nError: Can not find $search_name in hash\n";
	for my $key ( keys %orthology_hash ) {
		my @cur_line = @{$orthology_hash{$key}};
		my @remaining_elements = @cur_line;
		foreach (@ortholog_groups) {
			my $this_ortholog = $_;
			if ($this_ortholog ne '-' && $this_ortholog eq shift @remaining_elements) {
				if (exists ($out_hash{$key})) {
				} else {
					push @{ $out_hash{$key} }, @cur_line;
				}
				last;
			} 
		}
	}
	return %out_hash;
}


#-----------------------------------------------------
#	print output
	
sub sub_print {
		my ($search_name) = shift @_;
		my (%out_hash) = @_;
		my $outfile = "$search_name" . ".txt";
		$outfile =~ tr /\|/_/;
		open (OUTFILE, ">$outfile") or print "Error: cCould not open outfile.";
		for my $key ( keys %out_hash ) {
    		print OUTFILE join("\t",$key, @{$out_hash{$key}}), "\n";
		}
#		print OUTFILE "$print_out";
		close OUTFILE;
}


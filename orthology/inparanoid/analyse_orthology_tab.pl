#!/usr/bin/perl
#analyse orthology tab
use strict;
use warnings;

my $useage = "analyse_orthology_tab.pl <orthology_table.csv>";


my $infile = shift;
build_hash ($infile);
my %orthology_hash = build_hash ($infile);

search_gene (%orthology_hash);

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
	my ($infilebadger) = @_;
	open (INFILE, $infile); 
	my %hash;
	while (<INFILE>) {
 		my $cur_line = $_;
 		chomp $cur_line;
  		my @cur_line = split ("\t", $cur_line);
  		my $line_key = shift @cur_line;
 		foreach (@cur_line) {
			push @{ $hash{$line_key} }, $_;
 		}
 	}
 	return (%hash);
 }

#-----------------------------------------------------
#	Querying for a gene
sub search_gene {
	my (%hash) = @_;
	my $print_out = '';
	print "Please enter the name of the gene you wish to search for\n";
	my $search_name = <STDIN>;
	chomp $search_name;
	print "Would you like to print search results to an outfile?\ty\tn\n";
	my $print_switch = <STDIN>;
	chomp $print_switch;
	unless ($print_switch eq 'y'|'n') {print "Error: Answer y or n. Not printing results for now.\n";}
	print "\nLooking for gene:\t";
	print "$search_name\n\n";
	my @ortholog_groups = @{$orthology_hash{$search_name}} or print "\nError: Can not find gene in hash\n";
	print "Orthology groups are:\t";
	print "@ortholog_groups\n\n";
	print "Members of this ortholog group are:\n";
	for my $key ( keys %hash ) {
		my @cur_line = @{$hash{$key}};
		my @remaining_elements = @cur_line;
		foreach (@ortholog_groups) {
			my $this_ortholog = $_;
			if ($this_ortholog ne '-' && $this_ortholog eq (shift @remaining_elements)) {
				$print_out .= join ("\t", $key, @cur_line) . "\n";
				last;
			} 
		}
	}
	print "$print_out";
	if ($print_switch eq 'y') { sub_print ($search_name, $print_out)}

}
	

#-----------------------------------------------------
#	print output
	
sub sub_print {
		my ($search_name, $print_out) = @_;
		my $outfile = "$search_name" . ".txt";
		$outfile =~ tr /\|/_/;
		open (OUTFILE, ">$outfile") or print "Error: cCould not open outfile.";
		print OUTFILE "$print_out";
		close OUTFILE;
}



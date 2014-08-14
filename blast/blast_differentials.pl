#!/usr/bin/perl -w
use strict;
use Cwd;


#	blast_differentials.pl summarises the results of blast.sh accross multiple genomes.
#	It will indicate the presence/absence of blast results from each genome and output 
#	three files (tab delimited presence/absence in each genome): present_all.csv - 
#	genes present in all genomes; absent_all.csv - genes absent in all genomes; 
#	differentials.csv - genes present in some, but not all genomes.

my $usage="blast_differentials.pl <blast_pipe_outfile.csv> <blast_pipe_outfile.csv> <blast_pipe_outfile.csv>";



#-------------------------------------------------------
# 		Step 1.		Collect a list of input files; 
#		Loop through them, splitting them into lists
#		of queries with hits/no hits and also make a 
#		list of all query names for differentials file
#		later. A hit must align over 50% of the query
#		sequence for it to be considered.
#-------------------------------------------------------
#	
#		The position of the columns containing the number
#	of hits and the column containing percentage length of 
#	the query are automatically detected.
#

my @infiles = @ARGV;
my $infile;
my %out_hash;
my $cur_line;

print "$usage\n\n";
print "You have supplied the following infiles: @infiles\n";

foreach (@infiles) {
	my $infile = $_;
	my $id_pos = 0;
	my $length_pos = 0;
	my $hit_pos = 0;
	my $iteration;
	my $per_length;

	open (INFILE, "$infile") or die "\nERROR: $infile could not be opened\n"; 
	open (PRESENT_OUT, '>"$infile"_present.csv');
	open (ABSENT_OUT, '>"$infile"_absent.csv');
	open (PRESENCE_OUT, '>"$infile"_presence.csv');
	
	while (my $line = <INFILE>) {
		my @ao_line = split ('\t', $line);
		my $id = $ao_line[$id_pos];
		my $hit = $ao_line[$hit_pos];
		my $per_length = $ao_line[$length_pos];		
		if ($ao_line[0] =~ m/ID/) {
			foreach (@ao_line) { 
				if ($_ =~ m/No\.hits/) { 
					$hit_pos = $iteration;
					$length_pos = "$hit_pos" + 4; 
					last;
				}
				$iteration ++;
			}				
		} elsif ("$hit" >= 1 && $per_length && "$per_length" >= 0.5) {		
#			print PRESENT_OUT "$id\n";
#			print PRESENCE_OUT "$id\t0\n";
			$out_hash{"$id"} .= "1\t";
		} else {
			chomp $hit;
#			print ABSENT_OUT "$id\n";
#			print PRESENCE_OUT "$id\t0\n";
			$out_hash{"$id"} .= "0\t";
		}
	}
	close (PRESENT_OUT);
	close (ABSENT_OUT);
	close (PRESENCE_OUT);
}	



#-------------------------------------------------------
# 		Step 2.		Combine the total lists together to
#		make a .csv table of presence/absence of each query
#-------------------------------------------------------

open (PRESENCE_TAB, '>presence_tab.csv');
open (PRESENT_ALL, '>present_all.csv');
open (ABSENT_ALL, '>absent_all.csv');
open (DIFFERENTIAL, '>differential.csv');

my $presence_str = "1";
my $absence_str = "0";
foreach ( 1 .. $#infiles ) { $presence_str .= '\t1'; $absence_str .= '\t0'; }
foreach (keys %out_hash) {
	$cur_line = $out_hash{$_};
	print PRESENCE_TAB "$_: $cur_line\n";
	if ($cur_line =~ m/$presence_str/) {
		print PRESENT_ALL "$_\t$cur_line\n";
	} elsif ($cur_line =~ m/$absence_str/) {
		print ABSENT_ALL "$_\t$cur_line\n";
	} else { 
		print DIFFERENTIAL "$_\t$cur_line\n";
	}
}

close (PRESENCE_TAB);
close (PRESENT_ALL);
close (ABSENT_ALL);
close (DIFFERENTIAL);

exit
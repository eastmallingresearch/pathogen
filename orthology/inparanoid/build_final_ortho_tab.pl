#!/usr/bin/perl
use strict;
use warnings;
use Cwd;

my $usage = "build_final_ortho_tab.pl <directory_containing_ortholog_files> <output_directory>";

my $indir = shift or die $usage;
my $outdir;
my @strains = @ARGV;
my $ortho_group = 0;
my %ortho_tab;

opendir(DIR, $indir) or die $!;

my @out_header = ("ortho_group", "filename");
foreach (@strains) { push(@out_header, "$_"); }
print join ("\t", @out_header) . "\n"; 

while (my $file = readdir(DIR)) {
 	next if ($file =~ m/^\./);
#  	print "looking at:\n$file\n";
 	($ortho_group) = build_table($file, $ortho_group, @strains);
 }

closedir(DIR);
exit 0;


#-----------------------------------------------------
#	build ortholog table
#-----------------------------------------------------	

sub build_table {
	my ($file) = shift @_;
	my ($ortho_group) = shift @_;
	my (@strains) = @_;
	$ortho_group++;
	my $group_name = "ortho_group_" . "$ortho_group";
	my %hash_presence;
	# Build a hash to store presence/absence of an orthogroup in a strain
	foreach (@strains) {
		my $strain = $_;
		$hash_presence{$strain} = '-';
	}
# 	for my $key ( keys %hash_presence ) {
#   		print "$hash_presence{$key}\n";
#  	}
	# Get the strain the file came from from the filename
	foreach (@strains) {
		my $strain = $_;
		if ($file =~ m/^$strain/) {
			$hash_presence{$strain} = '+';
		}
	}
# 	for my $key ( keys %hash_presence ) {
#   		print "$hash_presence{$key}\n";
#  	}
	# Look at the names of the genes in the ortholog group and mark strains as present
 	open (INFILE, "$indir/$file");
 	while (<INFILE>) {
 		my ($cur_line) = $_;
 		chomp $cur_line;
 		my @ao_line = split ('\|', $cur_line );
 			foreach (@strains) {
 				my $strain = $_;
#  				print "ao_line[0] is : $ao_line[0]\n";
				if ($ao_line[0] =~ m/^$strain/) {
					$hash_presence{$strain} = '+';
				}
			}
#  		print "$cur_line\n";
 	}
 	my @ao_outline = ("$group_name", "$file");
	for my $key ( keys %hash_presence ) {
 # 		print "$key\t$hash_presence{$key}\n";
 		push (@ao_outline, "$hash_presence{$key}");
 	}
	print join ("\t", @ao_outline) . "\n"; 
#	exit;

	return ($ortho_group, %ortho_tab);
}	
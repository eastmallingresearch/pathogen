#!/usr/bin/perl
use strict;
use warnings;

my $usage = build_final_ortho_tab.pl <directory_containing_ortholog_files> <output_directory>

my $indir
my $outdir


opendir (DIR, $indir) or die $!;

foreach (my $file = readdir(DIR)) {
	print "looking at:\n$file\n";
}

exit

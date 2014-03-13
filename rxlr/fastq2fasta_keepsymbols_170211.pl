#!/usr/bin/perl
#questions to eric.kemen@bbsrc.ac.uk


use strict;
use warnings ;

# get filename and flow cell id ######################

my $usage = "$0 <sequence_file> <outfile2>\n";
die $usage unless $ARGV[0];

my $sequence_file = $ARGV[0] || die "Please provide sequence file" ;
my $outfile2 = $ARGV[1] || die "Please provide outfile2 name" ;

open (FILE, "<$sequence_file") || die "File $sequence_file doesn't exist!!";

# generate new filename with id no for out files #####

#      my @filname_split = split (/\_/, $sequence_file);
#      my $new_filname = "s_$filname_split[1]\_$filname_split[2]";

#my ($outfile1) = ("$new_filname.single-read");

#my ($outfile2) = ("$sequence_file.velvet.fan");

#open(OUTFILE1, ">$outfile1") or die "Failed to open file '$outfile1' for writing\n";

open (OUTFILE2, ">$outfile2") or die "Failed to open file '$outfile2' for writing\n";

# parse fiel and remove Ns ############################

while (my $id_line = <FILE>) {
    next if ($id_line !~ m/^\@HWI-E/);
    chomp $id_line;
    if ($id_line =~ m/^\@HWI-E/) {
    my $id = $1;
    my $seq_line =<FILE>;
    next if ($seq_line =~ m/N/);
    chomp $seq_line;
    if ($seq_line =~ m/^([ACGT]+)$/) {
        my $seq = $1;
        my $second_id_line = <FILE>;
        chomp $second_id_line;
        if ($second_id_line =~ m/^\+/) {
        my $quality_line = <FILE>;
        chomp $quality_line;
        if ($quality_line =~ m/^(\S+)/) {
            my $quality = $1;

# write illumina 1.3 fastq to sanger fastq #############

#	my $sanger_quality = &convertPhred($quality_line);

# remove symbols #######################################

#my @id_line_split = split (/\#/, $id_line);
#my @id_second_line_split = split (/\#/, $second_id_line);

# print individual files for reads in sanger fastq #####

#                print OUTFILE1 "$id_line_split[0]\_1\n";
#                print OUTFILE1 "$seq_line\n";
#                print OUTFILE1 "$id_second_line_split[0]\_1\n";
#                print OUTFILE1 "$sanger_quality\n";

# print fasta files #####################################

#$id_line_split[0] =~ s/@/>/g;
$id_line =~ s/@/>/g;

                print OUTFILE2 "$id_line\n";
                print OUTFILE2 "$seq_line\n";
            }
            }


    } else {
        die "Failed to parse seq line: $seq_line\n";
    }
    } else {
    die "Failed to parse id line: $id_line\n";
    }
}

# sub for conversion of q score ###########################

#sub convertPhred {
#	my $qstring = shift;
#	my @quals = split("",$qstring);
#	my $qual="";
#	my $scale_factor=31;
#	foreach my $q (@quals) {
#		my $newval = ord($q) - $scale_factor;
#		my $newqual = chr($newval);
#		$qual.=$newqual;
#	}
#	return $qual;
#
#}

close FILE;
close OUTFILE2;

exit;

#!/usr/bin/perl



### david.studholme@bbsrc.ac.uk


use strict;
use warnings ;
use Bio::SeqIO ;

my $sequence_file = shift or die "Usage: $0 <sequence file>\n" ;

my $inseq = Bio::SeqIO->new('-file' => "<$sequence_file",
			    '-format' => 'fasta' ) ;


### Keep count the number of sequences that have been read
my $number_of_seqs = 0 ;
my %lengths;

my @lengths2;
my $count = 0;
while (my $seq_obj = $inseq->next_seq ) {
  my $id = $seq_obj->id ;
  my $seq = $seq_obj->seq ;
  my $length = length($seq);
 
 
      push @lengths2, $length;
      $lengths{$length}{$id} = 1;
      $count++;
 
}

my @sorted = sort {$a<=>$b} keys %lengths;
my $lowest = shift @sorted;
my $highest = pop @sorted;

my @sorted2 = sort{$a <=> $b} @lengths2;
my $middle = int(scalar(@sorted2) / 2);
my $n50 = $sorted2[$middle];


my $total = 0;
my $step = 200;

my $coverage_length_threshold = 500;
my $coverage = 0;


for (my $i=0;$i<=$highest;$i+=$step) {
    
    my $n = 0;
    foreach my $j ($i .. ($i+$step-1) ) {
	$n += keys %{$lengths{$j}};
	#warn "$i\t$n\n";

	if ($j >= $coverage_length_threshold) {
	    foreach my $id (keys %{$lengths{$j}}) {
		$coverage += $j;
	    }
	}
    }
    
    print "$i-".($i+$step-1)."\t$n\n";
    
    $total += $n;
}

print "N50 = $n50\n";
print "Highest = $highest\n";
print "lowest = $lowest\n";
print "Total=$total\nCount=$count\n";
print "$coverage nt are covered by contigs >= $coverage_length_threshold nt long\n";

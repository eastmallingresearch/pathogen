#!/usr/bin/perl -w
use strict;
use Cwd;
use Bio::SeqIO;
use Bio::Tools::Run::StandAloneBlast;
use Bio::Search::Result::BlastResult;

# Blast a file of candidate effectors against themselves to establish 
# homology between query sequences

#-------------------------------------------------------
# 		Step 1.		Initialise values
#-------------------------------------------------------

my $usage = "blast_self.pl <query_file.fa> <database_name> > <outfile.csv>";
my $query_file = shift or die $usage;
my $database = shift or die $usage;
my @keys;
my $blast_obj;
my $result_obj;
my $report_obj;
my %hash;
my $hit_id;
my @ao_seqs;
my $seq;
my $read_no = 0;
my $outline_edit;
my @outline_start;
my @ao_arrays;
my %outline_hash;


#-------------------------------------------------------
# 		Step 2.		Create BLAST factory
#-------------------------------------------------------
 
$blast_obj = Bio::Tools::Run::StandAloneBlast->new('-program'  => 'blastp', '-database' => $database, '-e' => 1e-10);


#-------------------------------------------------------
# 		Step 3.		Collect sequence names from input
#------------------------------------------------------- 

my $seq_obj = Bio::SeqIO->new('-file' => $query_file, '-format' => "fasta", '-alphabet' => 'protein' );

while (my $seq = $seq_obj->next_seq) {push @ao_seqs, $seq};

#-------------------------------------------------------
# 		Step 3.		Create initial output line
#------------------------------------------------------- 

foreach (@ao_seqs) {
	$read_no ++;
	my $id = $_->id;
	push @keys, $id; 
	$hash{"$id"} = "$read_no";
	push @outline_start, '-';
}

#-------------------------------------------------------
# 		Step 3.	Create hash to reference for sequence order
#------------------------------------------------------- 

#my @keys = keys %hash;
print "header\t";
foreach (@keys) {print "$_\t";}
print "\n";

#-------------------------------------------------------
# 		Step 4.		Re-open input
#-------------------------------------------------------

$seq_obj = Bio::SeqIO->new('-file' => $query_file, '-format' => "fasta", '-alphabet' => 'protein' );

#-------------------------------------------------------
# 		Step 4.		Perform BLAST, collect hits, for each
#					hit collect the name, reference the hash
#					and modify the outline accordingly.
#-------------------------------------------------------

while (my $seq = $seq_obj->next_seq) {
	my @outline_edit;
	my @ao_homologs;
	my $id = $seq->id;
	@outline_edit = @outline_start;
	unshift @outline_edit, $id;	
	$report_obj = $blast_obj->blastall($seq);
 	$result_obj = $report_obj->next_result;
  	my @ao_hits = $result_obj->hits;
  	foreach (@ao_hits) {
  		my $hit = $_;
  		if ($hit) {  					
 			my $hit_id = $hit->name;
 			my $hit_element = $hash{$hit_id};
			push @ao_homologs, $hit_element;
			
			splice @outline_edit, "$hit_element", 1, '1';	 			
		}
  	}
	
#	$outline_hash{"$id"} = "@outline_edit";	
	foreach (@outline_edit) {
		print "$_\t";
	}		
	print "\n";
}

#print "\n";


# my @keys2 = keys %outline_hash;
# foreach (@keys2) {
# 	my @print_line = split ( ' ' , $outline_hash{"$_"});
# 	foreach (@print_line) {print "$_\t";}
# 	print "\n";
# }

exit;
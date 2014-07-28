#!/usr/bin/perl -w
use strict;
#use Cwd;
use Bio::SeqIO;
use Bio::Tools::Run::StandAloneBlast;
use Bio::Search::Result::BlastResult;

# Perform a tBlASTn search on a pre-made database and then parse the results 
# into a tab separated output

my $usage = "blast2csv.pl <query_file.fa> <database_name> > <outfile.csv>";
my $query_file = shift or die $usage;
my $database = shift or die $usage;
my $blast_obj;
my $result_obj;
my $report_obj;
my @ao_outlines;

#-------------------------------------------------------
# 		Step 1.		Set outfile header
#-------------------------------------------------------

my $outline_header = "ID\tSequence\tSequence_lgth\tNo.hits\tBest_hit\tE-value\tHit_lgth\tPer_length\tPer_ID\tHit_seq\n";
print "$outline_header";

#-------------------------------------------------------
# 		Step 2.		Create BLAST factory
#-------------------------------------------------------
 
$blast_obj = Bio::Tools::Run::StandAloneBlast->new('-program'  => 'tblastn', '-database' => $database);


#-------------------------------------------------------
# 		Step 3.		Open query file
#------------------------------------------------------- 

my $seq_obj = Bio::SeqIO->new('-file' => $query_file, '-format' => "fasta", '-alphabet' => 'dna' );

#-------------------------------------------------------
# 		Step 4.		Perform blast for each query
#-------------------------------------------------------
 
while (my $seq = $seq_obj->next_seq) {
 	$report_obj = $blast_obj->blastall($seq);
 	$result_obj = $report_obj->next_result;
  	my @ao_hits = $result_obj->hits;
  	my $hit = $ao_hits[0];

#-------------------------------------------------------
# 		Step 5.		Get query info
#-------------------------------------------------------	
 	my $seq_id =  $seq->id;
	my $sequence = $seq->seq;
	my $query_lgth = (($seq->length)*3);
	my $no_hits = $result_obj->num_hits;

#-------------------------------------------------------
# 		Step 6.		Declare and set hit values
#-------------------------------------------------------

	my $hit_id;
	my $hit_lgth;
	my $per_query;
	my $ident;
	my $per_id;
	my $e_value;		
 	my $hit_seq;
 	my $outline;
 	
 	if ($hit) {  					
 		my $hsp = $hit->hsp('best');
 		my $hit_id = $hit->name;
		my $hit_seq = $hsp->seq_str; 	
 		my $hit_lgth = length ($hit_seq);
 		my $per_query = ($hit_lgth / $query_lgth);
 		$per_query = substr $per_query, 0, 4;
 		my $ident = $hsp->num_identical();
		my $per_id = $hit->frac_identical;
		$per_id = substr $per_id, 0, 4;
		my $e_value = $hsp->evalue;			

 		
 		$outline = "$seq_id\t$sequence\t$query_lgth\t$no_hits\t$hit_id\t$e_value\t$hit_lgth\t$per_query\t$per_id\t$hit_seq\n";	
 	}
 	else {
		$outline = "$seq_id\t$sequence\t$query_lgth\t$no_hits\n";	

 	}

#-------------------------------------------------------
# 		Step 7.		Print BLAST info to outfile
#-------------------------------------------------------
 	
 	push @ao_outlines, $outline;
 	
 }
 
 foreach (@ao_outlines) { print "$_";}
 
 exit;
#!/usr/bin/perl


use warnings;
use strict;
use Bio::AlignIO;
use Bio::SeqIO;
use Bio::SimpleAlign;
use Bio::Tools::Run::StandAloneBlast;


#THIS SECTION TAKES EFFECTORS AND PARSES THEM INTO AN ARRAY OF SEQUENCES- YOU COULD 
#MAKE HAS OF ARRAYS AT THIS POINT- ONE FOR EACH EFFECTOR FAMILY
my $input_file = shift;
my $seq_in  = Bio::SeqIO->new(
                              -format => 'fasta',
                              -file   => $input_file,
                              );
my $seq;
my @seq_array;
while( $seq = $seq_in->next_seq() ) {
    push(@seq_array,$seq);
}

#THERE SHOULD THEN BE A LOOP HERE THAT DOES WHAT IS BELOW FOR EACH EFFECTOR FAMILY 
#RATHER THAN THE WHOLE EFFECTOR LIST

print "EFFECTOR BLASTING\n";
#THIS SETS PARAMATERS FOR THE BLAST- CURRENTLY HARD CODED
my @params = (program  => 'tblastn', database => "ps_aq" );
my $blast_obj = Bio::Tools::Run::StandAloneBlast->new(@params);   
my @aohits=();

#THIS LOOPS THROUGH EACH SEQUENCE- BLASTING IT TO THE GENOME
foreach (@seq_array){
	print "Blasting ".$_->id()." \n";
	my  $report_obj = $blast_obj->blastall($_);
	#THIS FILTERS AND RETURNS THE REPORT- NEED AN E VAL THRESHOLD
	my %hits=report_filter($report_obj,$_); 
	
	#THIS TAKES GOOD DATA AND PUTS THE REPORT IN AN ARRAY
	if (scalar(keys %hits)>0){
       				#print ("RETURNING VALID HITS ", %hits,"\n");
       				push (@aohits,\%hits)
       			} 
}

#FOR EACH ARRAY OF HITS THERE NEEDS TO BE SOME FURTHER FILTERING FOR OUTPUT DATA
#WHICH NEEDS TO BE IN SOME KIND OF TABLE FORMAT?





########SUBROUTINES###########

sub report_filter{
	my ($report_obj,$seq)=@_;
	my $query_length=$seq->length();
	my $query_name=$seq->id();
	my %hashofhits=();


	print ("Query Length ", $query_length,"\n");
	#LOOP THROUGH RESULTS
		while(my $result = $report_obj->next_result ) {
       				my $hitcount= $result->num_hits;
       				print "HIT COUNT ". $hitcount."\n";
       				#LOOP THROUGH HITS
 			 			 while( my $hit = $result->next_hit ) {
 			 			 	my $name=$hit->name();	
 			 			 	#LOOP THROUGH HSPS 			 	
   								while( my $hsp = $hit->next_hsp ) {
   		  								if( $hsp->length('total') >50 && $hsp->frac_identical( ['query'|'hit'|'total']) >0.5 ) {
          										my @arrayofdata=();
          											print "BLAST REPORT\n";
          											print "Scaffold $name \t";
          											print "Query $query_name \t";
          											push (@arrayofdata,$query_name);
          											push(@arrayofdata,$name);
          											my $hit=$hsp->hit;
          											#	print ( "Descriptor ", $hit->seqdesc, "\n");
          											push(@arrayofdata, $hit->seqdesc);
          											print $hsp->hit_features."\n";
          											print $hit->annotation()->display_text();
          											print ("Frac ident ", $hsp->frac_identical( ['query'|'hit'|'total']),"\n" );
          											push(@arrayofdata,$hsp->frac_identical( ['query'|'hit'|'total']));
   													print ( "Hit length ", $hsp->length, "\n");
   													push(@arrayofdata,$hsp->length);
   	 												print ( "Hit rank ", $hsp->rank,"\n");
   	 												push(@arrayofdata,$hsp->rank);
    												print ("Hit start ",$hsp->start('hit'),"\n");
    												push(@arrayofdata,$hsp->start('hit'));
 											     	print ("Hit end " , $hsp->end('hit'), "\n");
 											     	push(@arrayofdata,$hsp->end('hit'));
 											       print ("Strand " , $hsp->strand('hit'), "\n");
 											     	push(@arrayofdata,$hsp->strand('hit'));
     												print $hsp->seq( 'hit' )->seq."\n\n";
     												$hashofhits{$name}=\@arrayofdata;
          								}
    				       			}
			 			 		}
       			 			}		
		return %hashofhits;
}


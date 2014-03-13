#!/usr/bin/perl -w

use strict;
use warnings;
use Bio::SeqIO;
use Bio::SearchIO;
#use CGI;
use lib '/home/studhold/usr/local/share/perl/5.8.8';
use Statistics::Descriptive;
use Cwd;


my $dir= getcwd; ;

my $genome = "/home/studhold/projects_sainsbury_lab/sequence-assembly/simulations/Pseudomonas_syringae_pv_B728a.fna";
my $genes = "/home/studhold/projects_sainsbury_lab/sequence-assembly/simulations/genes/NC_007005.ffn";


my $genome_size = shift;

### Get a list of directories
my @cluster_dirs;

opendir(DIR, $dir) or die "can't opendir $dir: $!";
my @files = readdir(DIR);
foreach my $file (@files) {
    if (
	-d $file
	) {
	warn "'$dir/$file' is a directory\n";

	push @cluster_dirs, "$dir/$file"  unless $dir =~ m/^\.+$/ or $file =~ m/^\.+$/;
    }
}
close DIR;
    

#my $cgi = new CGI;
#print $cgi->start_html;

print "\"$dir\"\n\n";
if (defined $genome_size) {
    print "\"assuming genome size = $genome_size\"\n\n"; 
}

print "\"Assembly\"\t";
print "\"N\"\t";	
if (defined $genome_size) {
    print "N50 length\t";
    print "N50 number\t";
}
print "\"Mean\"\t";
#print "\"Variance contig length\"\t";
print "\"Median\"\t";
print "\"Sum\"\t";	    
print "\"Longest\"\t";
print "\"Reads\"\t";
print "\n";
		
foreach my $dirname (sort @cluster_dirs) {
   # warn "Processing '$dirname'\n";
    opendir(DIR, $dirname) or die "can't opendir $dirname: $!";
    my @files = readdir(DIR);
    
    
    foreach my $file (@files) { 
  

	if ($file =~ m/Graph|^core$/ and
	    -s "$dirname/contigs.fa") {
	    my $cmd = "rm $dirname/$file";
	   # warn "$cmd\n";
	    system $cmd;
	}

	if ($file =~ m/^contigs.fa$|\d+\.contigs$/) {
	   # warn "$dirname/$file\n";

	    my $trimmed_dirname = $dirname;
	    $trimmed_dirname =~ s/^.*\/(.*?)$/$1/;

	   # warn "$dirname => $trimmed_dirname\n";

	    



	    ### Describe the length distribution for the contigs
	    my @lengths;
	    my $inseq = Bio::SeqIO->new('-file' => "<$dirname/$file",
					'-format' => 'fasta' ) ;
	    while (my $seq_obj = $inseq->next_seq ) {
		my $id = $seq_obj->id ;
		my $seq = $seq_obj->seq ;
		my $desc  = $seq_obj->description ;
		if (length($seq)) {
		    push @lengths, length($seq);
		}
	    }

	    my $stat = Statistics::Descriptive::Full->new();
	    $stat->add_data(@lengths); 
	    my $mean = int $stat->mean();
	    my $var  = int $stat->variance();
	    my $median = int $stat->median();
	    my $max = int $stat->max();
	    my $sum = int $stat->sum();
	    
	    

	    my $n50_contig_length = 0;
	    my $n50_contig_number = 0;
	    my $n50_sum = 0;

	    if (defined $genome_size) {
		### Calculate N50
		my @sorted_lengths = sort {$b<=>$a} @lengths;

		while ($n50_sum <= ($genome_size/2)
		       and @sorted_lengths) {
		    $n50_contig_length = shift @sorted_lengths;
		    $n50_contig_number++;
		    $n50_sum += $n50_contig_length;
		}
	    }
	    
	    my $reads=0;
	    if ($dirname =~ m/subset\.(\d+)\./) {
		$reads = $1;
	    }


	    if (@lengths) {
		my $n = @lengths;
		print "\"$trimmed_dirname/$file\"\t";
		print "$n\t";	
		if (defined $genome_size) {
		    print "$n50_contig_length\t";
		    print "$n50_contig_number\t";
		}
		print "$mean\t";
		#print "$var\t";
		print "$median\t";
		print "$sum\t";	    
		print "$max\t";
		print "$reads\t";
		print "\n";
		
	    }




	    if (0) {
		### Align contigs against genome
		my $genome_blat_outfile = "$dirname/velvet-contigs.versus.genome.psl";
		unless (-s $genome_blat_outfile and 0) {
		    my $cmd = "blat $genome $dirname/$file $genome_blat_outfile";
		    warn "$cmd\n";
		    my $execute = `$cmd`;
		    warn "$execute\n";
		}
		
		### Parse the contigs versus genome
		my $parse_genome_script = "/home/studhold/scripts/sequence_assembly/parse_genome_blat.pl";
		my $genome_matches_outfile = "$dirname/velvet-contigs.versus.genome.match-lengths.txt";
		unless (-s $genome_matches_outfile and 0) {
		    my $cmd = "$parse_genome_script $genome_blat_outfile > $genome_matches_outfile";
		    warn "$cmd\n";
		    my $execute = `$cmd`;
		    warn "$execute\n";
		}
	    }

	    if (0) {
		
		### Align contigs against genes
		my $genes_blat_outfile = "$dirname/velvet-contigs.versus.genes.psl";
		unless (-s $genes_blat_outfile and 0) {
		    my $cmd = "blat $genes $dirname/$file $genes_blat_outfile";
		    warn "$cmd\n";
		    my $execute = `$cmd`;
		    print "$execute\n";
		}
		
		### Parse the contigs versus genes
		my $parse_genes_script = "/home/studhold/scripts/sequence_assembly/parse_genes_blat.pl";
		foreach my $coverage (100, 90, 50) {
		    my $genes_matches_outfile = "$dirname/velvet-contigs.versus.genes.match-lengths.$coverage-pc.txt";
		    unless (-s $genes_matches_outfile and 0) {
			my $cmd = "$parse_genes_script $genes_blat_outfile $coverage > $genes_matches_outfile";
			warn "$cmd\n";
			my $execute = `$cmd`;
			warn "$execute\n";
		    }
		}
		
		
	    }
	}
    }
}

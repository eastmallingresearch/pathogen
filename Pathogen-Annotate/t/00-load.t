#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Pathogen::Annotate' ) || print "Bail out!\n";
}

diag( "Testing Pathogen::Annotate $Pathogen::Annotate::VERSION, Perl $], $^X" );

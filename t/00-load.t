#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use lib 'lib';

plan tests => 1;

BEGIN {
    use_ok( 'MS2::Parser' ) || print "Bail out!\n";
}

diag( "Testing MS2::Parser $MS2::Parser::VERSION, Perl $], $^X" );

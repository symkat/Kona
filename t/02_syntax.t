#!/usr/bin/perl
use warnings;
use strict;
use local::lib '~/perl5';
use lib 'lib';
use Test::More;

is( system( "perl dispatch.fcgi -c" ), 0 ) || BAIL_OUT( "perl dispatch.fcgi -c must run without errors" );

done_testing();

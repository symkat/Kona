#!/usr/bin/perl
use warnings;
use strict;
use local::lib '~/perl5';
use lib 'lib';
use Data::Dumper;

###### Internal Libs ########
use Site::Schema;     # DBIC
use Site::Config;     # YAML + Conf Validator

####### Conf/DB Setup ########
my $config = Site::Config->load_config( 'conf/t_conf/conf.yaml' );

my $schema = Site::Schema->connect( 
    "dbi:Pg:host=" . $config->{database}->{hostname} .
    ";dbname=" . $config->{database}->{database}, 
    $config->{database}->{username}, 
    $config->{database}->{password},
);


# Make sure this is a clean DB

my $rs = $schema->resultset( 'Article' );
my $found_2_1 = $rs->search( {  uri => '/random', 'article_revisions.revision' => 1 }, { join => 'article_revisions' } );


print Dumper $found_2_1->first->article_revisions->revision;

#!/usr/bin/perl
use warnings;
use strict;
use local::lib '~/perl5';
use lib 'lib';
use Test::More;
use Test::Exception;

###### Internal Libs ########
use Site::Schema;     # DBIC
use Site::Config;     # YAML + Conf Validator

####### Conf/DB Setup ########
ok my $config = Site::Config->load_config( 'conf/t_conf/conf.yaml' );

ok my $schema = Site::Schema->connect( 
    "dbi:Pg:host=" . $config->{database}->{hostname} .
    ";dbname=" . $config->{database}->{database}, 
    $config->{database}->{username}, 
    $config->{database}->{password},
);


# Make sure this is a clean DB

if ( $schema->resultset('Article')->count() != 0 ) {
    BAIL_OUT("Test Clean DBs only.");
}

my $rs = $schema->resultset( 'Article' );

# Create 3 articles and 3 revisions of each article.

my $entry_1 = $rs->create({ uri => '/hello-world', article_revisions => [
    {
        content  => "The Wiki!",
        title    => "Hello World",
        address  => "127.0.0.1",
        revision => 1,
    }
]});

$entry_1->live_revision( 1 );
$entry_1->update();

my $entry_2 = $rs->create({ uri => '/random', article_revisions => [
    {
        content  => "The Random Page",
        title    => "Random",
        address  => "127.0.0.1",
        revision => 1,
    }
]});

$entry_2->live_revision( 1 );
$entry_2->update();


# Add An Article Revision
my $entry_2_1 = $rs->find( { uri => '/random' },  { prefetch => 'article_revision' } );


my $entry_2_2 = $rs->find( { uri => '/random' } )->create_related( 'article_revision',
    {
        content  => "This random page is not so random.",
        title    => "Random",
        address  => "192.168.1.1",
        revision => $entry_2_1->article_revisions->get_column('revision')->max() + 1,
    }
);

$entry_2_1->live_revision( $entry_2_2->revision() );
$entry_2_1->update();


# Check If The Article Revisions Match

my $found_1   = $rs->find( { uri => '/hello-world' }, { prefetch => 'article_revision' } );
my $found_2   = $rs->find( { uri => '/random' }, { prefetch => 'article_revision' } );

is( $found_1->live_revision, 1 );
is( $found_2->live_revision, 2 );

# Check The Content Of The Articles

is( $found_1->article_revision->content(), "The Wiki!" );
is( $found_1->article_revision->title(), "Hello World" );
is( $found_1->article_revision->address(), "127.0.0.1" );
is( $found_1->article_revision->revision(), "1" );
is( $found_1->live_revision(), "1" );


is( $found_2->article_revision->content(), "This random page is not so random." );
is( $found_2->article_revision->title(), "Random" );
is( $found_2->article_revision->address(), "192.168.1.1" );
is( $found_2->article_revision->revision(), "2" );
is( $found_2->live_revision(), "2" );


SKIP: {
    skip "Pulling a specific revision might need some DBIC resultset changes", 5;
    my $found_2_1 = $rs->find( { uri => '/hello-world', "article_revision.revision" => 1 }, { join => 'article_revision' } );
    is( $found_2_1->article_revision->content(), "The Random Page" );
    is( $found_2_1->article_revision->title(), "Random" );
    is( $found_2_1->article_revision->address(), "127.0.0.1" );
    is( $found_2_1->article_revision->revision(), "1" );
    is( $found_2_1->live_revision(), "2" );
}


# Delete all revisions


# Check if everything is deleted.



done_testing();

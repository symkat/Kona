#!/usr/bin/perl
use warnings;
use strict;
use local::lib '~/perl5';
use lib 'lib';

####### External Libs ########
use Plack::Middleware::ContentLength;
use Plack::Middleware::LighttpdScriptNameFix;
use Plack::Middleware::GuessContentType;
use Plack::Request;

####### Internal Libs ########
use Site;           # Heap + General Stuff
use Site::Dispatch; # Custom Dispatch Table Loader
use Site::Schema;   # DBIC
use Site::Config;   # YAML + Conf Validator

## Page Handlers ##
use Site::Pages::View;
use Site::Pages::Edit;
use Site::Pages::Create;
use Site::Pages::Static;
use Site::Pages::Special::Listing;
use Site::Pages::Special::Search;

####### Conf/DB Setup ########
my $config = Site::Config->load_config( 'conf/development.yaml' );

my $schema = Site::Schema->connect( 
    "dbi:Pg:host=" . $config->{database}->{hostname} .
    ";dbname=" . $config->{database}->{database}, 
    $config->{database}->{username}, 
    $config->{database}->{password},
);

####### Global Heap ########
$Site::heap{'schema'} = $schema;
$Site::heap{'config'} = $config;

my $app = Site::Dispatch->new( 
    [
        { url => qr/^\/$/,                      call => \&Site::Pages::View::handle   },
        { url => qr/^\/[a-zA-Z0-9_-]+$/,        call => \&Site::Pages::View::handle   },
        { url => qr/^\/!edit\/$/,               call => \&Site::Pages::Edit::handle   },
        { url => qr/^\/!edit\/[a-zA-Z0-9_-]+$/, call => \&Site::Pages::Edit::handle   },
        { url => qr/^\/!create$/,               call => \&Site::Pages::Create::handle },
        { url => qr/^\/!articles$/,             call => \&Site::Pages::Special::Listing::handle },
        { url => qr/^\/!search$/,               call => \&Site::Pages::Special::Search::handle },
        { url => qr/^.*$/,                      call => \&Site::Pages::Static::handle, test => \&Site::Pages::Static::can_send },
    ],
);

$app = Plack::Middleware::ContentLength->wrap($app);
$app = Plack::Middleware::LighttpdScriptNameFix->wrap($app);
$app = Plack::Middleware::GuessContentType->wrap($app);

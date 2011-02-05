#!/usr/bin/perl
use strictures 1;
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
use Site::Pages;

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
        { url => qr/^\/$/,                      call => \&Site::Pages::View::handle, package => "Site::Pages::View"  },
        { url => qr/^\/[a-zA-Z0-9_-]+$/,        call => \&Site::Pages::View::handle, package => "Site::Pages::View"  },
        { url => qr/^\/!edit\/$/,               call => \&Site::Pages::Edit::handle, package => "Site::Pages::Edit"  },
        { url => qr/^\/!edit\/[a-zA-Z0-9_-]+$/, call => \&Site::Pages::Edit::handle, package => "Site::Pages::Edit"  },
        { url => qr/^\/!create$/,               call => \&Site::Pages::Create::handle, package => "Site::Pages::Create" },
        { url => qr/^\/!articles$/,             call => \&Site::Pages::Special::Listing::handle, package => "Site::Pages::Special::Listing" },
        { url => qr/^\/!search$/,               call => \&Site::Pages::Special::Search::handle,  package => "Site::Pages::Special::Search" },
        { url => qr/^.*$/,                      call => \&Site::Pages::Static::handle, package => "Site::Pages::Static", test => \&Site::Pages::Static::can_send },
    ],
);

$app = Plack::Middleware::ContentLength->wrap($app);
$app = Plack::Middleware::LighttpdScriptNameFix->wrap($app);
$app = Plack::Middleware::GuessContentType->wrap($app);

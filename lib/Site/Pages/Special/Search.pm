package Site::Pages::Special::Search;
use strict;
require Exporter;
our @ISA = qw/ Exporter /;
our @EXPORT = qw/ /;

use Site::Utils;

# Let's play pretend...

sub handle {
    my ( $req ) = @_;
    my ( $res, $con, $uri ) = get_request_info( $req );
    my $content;

    if ( $con eq 'POST' ) {
        $res->redirect( "/" . $req->param( "search" ) ); 
        return $res;
    }

    $res->status(405);
    $res->body( "Method Not Allowed" );
    return $res;
}
1;

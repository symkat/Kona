package Site::Pages::Special::Listing;
use strict;
require Exporter;
our @ISA = qw/ Exporter /;
our @EXPORT = qw/ /;

use Site::Utils;

my $tt = get_template();

sub handle {
    my ( $req ) = @_;
    my ( $res, $con, $uri ) = get_request_info( $req );
    my $content;

    if ( $con eq 'GET' ) {
        # Handle Get
       
        my ( @articles ) = $Site::heap{'schema'}->resultset('Article')->all();
        if ( @articles ) {
            $tt->process( 'articles.tt2', { articles => \@articles }, \$content ) || die $tt->error();
            $res->body( $content );
            return $res;
        }
    }

    $res->status(405);
    $res->body( "Method Not Allowed" );
    return $res;
}

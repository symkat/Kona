package Site::Pages::Special::Listing;
use strict;

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

    return http_method_not_allowed( $res );
}

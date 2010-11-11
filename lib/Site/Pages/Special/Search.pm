package Site::Pages::Special::Search;
use strict;

use Site::Utils;

# Let's play pretend...

sub handle {
    my ( $req ) = @_;
    my ( $res, $con, $uri ) = get_request_info( $req );

    if ( $con eq 'POST' ) {
        $res->redirect( "/" . $req->param( "search" ) ); 
        return $res;
    }

    return http_method_not_allowed( $res );
}
1;

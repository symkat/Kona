package Site::Pages::View;
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
        my $entry = $Site::heap{'schema'}->resultset('Article')->find( { uri => $uri }, { prefetch => 'article_revision' } );
        if ( $entry ) {
            $tt->process( 'view.tt2', { entry => $entry }, \$content ) || die $tt->error();
            $res->body( $content );
            return $res;
        } else {
            $tt->process( 'create.tt2', { uri => $uri }, \$content ) || die $tt->error();
            $res->body( $content );
            return $res;
        }
    }
    return http_method_not_allowed( $res );
}

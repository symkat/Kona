package Site::Pages::Static;
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
        
        if ( $Site::heap{'config'}->{'server'}->{'x_send_file'} ) {
            $res->header( 'x-sendfile' => $Site::heap{'config'}->{'paths'}->{'static_files'} . $uri );
            return $res;
        }

        $res->body( "GET Request [" . __FILE__ . "]" );
        return $res;
    } 
    $res->status(405);
    $res->body( "Method Not Allowed" );
    return $res;
}

sub can_send {
    my ( $req ) = @_;
    my ( $res, $con, $uri ) = get_request_info( $req );
    
    return 0 if $uri =~ /\.\./;
    return 0 unless -e $Site::heap{'config'}->{'paths'}->{'static_files'} . $uri;
    return 1;
}

1;

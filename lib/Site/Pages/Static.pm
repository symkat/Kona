package Site::Pages::Static;
use strictures 1;
use base qw/ Site::Pages /;

sub can_send {
    my ( $req ) = @_;
    my ( $res, $con, $uri ) = get_request_info( $req );
    
    return 0 if $uri =~ /\.\./;
    return 0 unless -e $Site::heap{'config'}->{'paths'}->{'static_files'} . $uri;
    return 1;
}

sub handle_GET {
    my ( $self ) = @_;
    if ( $self->config->{'server'}->{'x_send_file'} ) {
        $self->res->header( 'x-sendfile' => $self->config->{'paths'}->{'static_files'} . $self->req->path );
        return $self->res;
    }
}


1;

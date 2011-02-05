package Site::Pages::Special::Search;
use strictures 1;
use base qw/ Site::Pages /;

# Let's play pretend...

sub handle_POST {
    my ( $self ) = @_;
    return $self->redirect( '/' . $self->req->param( "search" ));
}
1;

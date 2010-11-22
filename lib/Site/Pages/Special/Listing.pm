package Site::Pages::Special::Listing;
use strictures 1;
use base qw/ Site::Pages /;

sub handle_GET {
    my ( $self ) = @_;
    
    my ( @articles ) = $self->schema->resultset('Article')->all();
    if ( @articles ) {
        return $self->render_page( $self->res, 'articles.tt2', { articles => \@articles } );
    } # TODO: Handle case of no articles to display.
}
1;

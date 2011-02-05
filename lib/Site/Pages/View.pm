package Site::Pages::View;
use strictures 1;
use Text::MultiMarkdown;
use base qw/ Site::Pages /;

my $m = Text::MultiMarkdown->new( 
    empty_element_suffix => '>', 
    tab_width => 2,
    use_wikilinks => 1,
);

sub handle_GET {
    my ( $self ) = @_;

    my $entry = $self->schema->resultset('Article')->find( { uri => $self->req->path }, { prefetch => 'article_revision' } );
    
    unless ( $entry ) {
        return $self->render_page( $self->res, 'create.tt2', { uri => $self->req->path } );
    }
    my $html = $m->markdown( $entry->article_revision->content() );
    return $self->render_page( $self->res, 'view.tt2', { entry => $entry, markdown_content => $html } );
}

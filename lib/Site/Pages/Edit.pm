package Site::Pages::Edit;
use strictures 1;
use Text::MultiMarkdown;
use base qw/ Site::Pages /;


my $m = Text::MultiMarkdown->new(
    empty_element_suffix => '>',
    tab_width => 2,
    use_wikilinks => 1,
);

sub handle_POST {
    my ( $self ) = @_;
    my $title   = $self->req->param( 'title' );
    my $content = $self->req->param( 'rawcontent' );
    my $path    = $self->req->param( 'uri' );
    
    my $previous = $self->schema->resultset('Article')->find( { uri => $path }, { prefetch => 'article_revision' } );
    
    my @errors;

    push @errors, "URLs must be alphanumerical and allows - and _ characters." if $path !~ /^\/[a-zA-Z-_]+$/ and $path ne '/';
    # TODO: Reasonable title restrictions
    #push @errors, "Titles may be alphanumerical and contain spaces, underscores (_) and dashes (-)." if $title !~ /^[a-zA-Z0-9-_\s]+$/;
    push @errors, "Failed to load this article for editing." unless $previous;

    if ( @errors ) {
        # TODO: Reasonable error reporting.
        die "We had an error: " . join( "\n", @errors );
    }
    
    my $new_entry = $self->schema->resultset('Article')->find( { uri => $path } )->create_related( 'article_revision', 
            { content => $content, title => $title, address => $self->req->address, revision =>  $previous->article_revisions->get_column('revision')->max() + 1 } );
    my $article = $self->schema->resultset('Article')->find( { uri => $path } );
    $article->live_revision( $new_entry->revision() );
    $article->update();
    
    return $self->redirect($path);
}

sub handle_GET {
    my ( $self ) = @_;

    my $path = substr( $self->req->path, 6 ); # Remove /!edit  TODO: This is *really* ugly...
    my $entry = $self->schema->resultset('Article')->find( { uri => $path }, { prefetch => 'article_revision' } );
    if ( $entry ) {
        # Serve Entry
        return $self->render_page( $self->res, 'edit.tt2', { entry => $entry, rawcontent => $entry->article_revision->content(), 
                preview => { content => $m->markdown($entry->article_revision->content()) } } );
    } else {
        # TODO
        # Be nice, Replcate create.pm
        return $self->render_page( $self->res, 'edit.tt2', {} );
    }
}

1;

package Site::Pages::Create;
use strictures 1;
use base qw/ Site::Pages /;

sub handle_POST {
    my ( $self ) = @_;

    my $title   = $self->req->param( 'pagetitle' );
    my $content = $self->req->param( 'rawcontent' );
    my $path    = $self->req->param( 'uri' );
    
    my @errors;

    push @errors, "URLs must be alphanumerical and allows - and _ characters." if $path !~ /^\/[a-zA-Z-_]+$/ and $path ne '/';
    push @errors, "Titles may be alphanumerical and contain spaces, underscores (_) and dashes (-)." if $title !~ /^[a-zA-Z0-9-_\s]+$/;
    push @errors, "This article exists.  You may want to edit the article here instead." if $self->schema->resultset('Article')->search( { uri => $path } )->count();

    # Bombing out on errors.
    if ( @errors ) {
        return $self->render_page( $self->res, 'create.tt2', { uri => $path, content => $content, title => $title, errors => \@errors });
    }

    my $rs = $self->schema->resultset('Article');
    my $entry = $rs->create( { uri => $path, article_revisions => [ { content => $content, title => $title, address => $self->req->address(), revision => 1 } ] } );
    $entry->live_revision( 1 );
    $entry->update();
    
    return $self->redirect( $path );
}

1;

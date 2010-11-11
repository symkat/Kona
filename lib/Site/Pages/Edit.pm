package Site::Pages::Edit;
use strictures 1;

use Site::Utils;
use Text::MultiMarkdown;

my $m = Text::MultiMarkdown->new(
    empty_element_suffix => '>',
    tab_width => 2,
    use_wikilinks => 1,
);

my $tt = get_template();

sub handle {
    my ( $req ) = @_;
    my ( $res, $con, $uri ) = get_request_info( $req );
    my $content;

    if ( $con eq 'GET' ) {
        # Handle Get
        
        my $path = substr( $uri, 6 ); # Remove /!edit
        my $entry = $Site::heap{'schema'}->resultset('Article')->find( { uri => $path }, { prefetch => 'article_revision' } );
        if ( $entry ) {
            # Serve Entry
            $tt->process( 'edit.tt2', { entry => $entry, rawcontent => $entry->article_revision->content(), 
                    preview => { content => $m->markdown($entry->article_revision->content()) } }, \$content ) || die $tt->error();
            $res->body( $content );
            return $res;
        } else {
            # TODO
            # Be nice, Replcate create.pm
            $tt->process( 'edit.tt2', {  }, \$content );
            $res->body( $content );
            return $res;
        }

        $res->body( "GET Request [" . __FILE__ . "]" );
        return $res;
    } elsif ( $con eq 'POST' ) {
        # Handle Post
        my $title   = $req->param( 'title' );
        my $content = $req->param( 'rawcontent' );
        my $path    = $req->param( 'uri' );
        
        my $previous = $Site::heap{'schema'}->resultset('Article')->find( { uri => $path }, { prefetch => 'article_revision' } );
        
        my @errors;

        push @errors, "URLs must be alphanumerical and allows - and _ characters." if $path !~ /^\/[a-zA-Z-_]+$/ and $path ne '/';
        #push @errors, "Titles may be alphanumerical and contain spaces, underscores (_) and dashes (-)." if $title !~ /^[a-zA-Z0-9-_\s]+$/;
        push @errors, "Failed to load this article for editing." unless $previous;

        if ( @errors ) {
            die "We had an error: " . join( "\n", @errors );
        }
        
        my $new_entry = $Site::heap{'schema'}->resultset('Article')->find( { uri => $path } )->create_related( 'article_revision', 
                { content => $content, title => $title, address => $req->address(), revision =>  $previous->article_revisions->get_column('revision')->max() + 1 } );
        my $article = $Site::heap{'schema'}->resultset('Article')->find( { uri => $path } );
        $article->live_revision( $new_entry->revision() );
        $article->update();
        

        $res->redirect( $path );
        return $res;
    }
    
    return http_method_not_allowed( $res );
}

1;

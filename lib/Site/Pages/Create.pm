package Site::Pages::Create;
use strict;

use Site::Utils;

my $tt = get_template();

sub handle {
    my ( $req ) = @_;
    my ( $res, $con, $uri ) = get_request_info( $req );
    my $content;

    if ( $con eq 'POST' ) {
        # Handle Post
        my $title   = $req->param( 'pagetitle' );
        my $content = $req->param( 'rawcontent' );
        my $path    = $req->param( 'uri' );
        
        my @errors;

        push @errors, "URLs must be alphanumerical and allows - and _ characters." if $path !~ /^\/[a-zA-Z-_]+$/ and $path ne '/';
        push @errors, "Titles may be alphanumerical and contain spaces, underscores (_) and dashes (-)." if $title !~ /^[a-zA-Z0-9-_\s]+$/;
        push @errors, "This article exists.  You may want to edit the article here instead." if $Site::heap{'schema'}->resultset('Article')->search( { uri => $path } )->count();

        # Bombing out on errors.
        if ( @errors ) {
            $tt->process( 'create.tt2', { uri => $path, content => $content, title => $title, errors => \@errors }, \$content );
            $res->body( $content );
            return $res;
        }

        my $rs = $Site::heap{'schema'}->resultset('Article');
        my $entry = $rs->create( { uri => $path, article_revisions => [ { content => $content, title => $title, address => $req->address(), revision => 1 } ] } );
        $entry->live_revision( 1 );
        $entry->update();
        
        $res->redirect( $path );
        return $res;
    }
    
    return http_method_not_allowed( $res );
}

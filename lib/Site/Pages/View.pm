package Site::Pages::View;
use strict;

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
        my $entry = $Site::heap{'schema'}->resultset('Article')->find( { uri => $uri }, { prefetch => 'article_revision' } );
        if ( $entry ) {
            my $html = $m->markdown( $entry->article_revision->content() );
            $tt->process( 'view.tt2', { entry => $entry, markdown_content => $html }, \$content ) || die $tt->error();
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

package Site::Pages;
use strictures 1;
use Site::Utils;
use Moo;

has config => ( is => 'ro' );
has schema => ( is => 'ro' );
has req => ( is => 'rw' );
has res => ( is => 'rw' );

my $tt = get_template();

sub redirect {
    my ( $self, $url ) = @_;
    $self->res->redirect( $url );
    return $self->res;
}

sub render_page {
    my ( $caller, $res, $template, $template_data ) = @_; my $content;
    $tt->process( $template, $template_data, \$content ) || die $tt->error();
    $res->body( $content );
    return $res;
}

1;

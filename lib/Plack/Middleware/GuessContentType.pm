package Plack::Middleware::GuessContentType;
use strict;
use warnings;
use parent qw( Plack::Middleware );
use File::MMagic;
use Data::Dumper;
use Plack::Util;

my $mm = File::MMagic->new();

sub call {
    my $self = shift;
    my $res  = $self->app->(@_);

    return $self->response_cb($res, sub {
        my $res = shift;
        my $h = Plack::Util::headers($res->[1]);
        unless ( Plack::Util::status_with_no_entity_body($res->[0]) || $h->exists( 'Content-Type' ) || ! $h->exists( 'x-sendfile' ) ) {
            my $body = $res->[2];
            if ( ref $body eq 'ARRAY' and Plack::Util::status_with_no_entity_body($res->[0]) ) {
                my $real_body = join( "", @{$body} );
                if ( my $type = $mm->checktype_contents( $real_body ) ) {
                    $h->push( 'Content-Type' => $type );
                }
            } elsif ( $h->exists( 'x-sendfile' ) ) {
                if ( my $type = $mm->checktype_filename( $h->get('x-sendfile') )  ) {
                    $h->push( 'Content-Type' => $type );
                }
            } else {
                if ( my $type = $mm->checktype_filehandle( $body ) ) {
                    $h->push( 'Content-Type' => $type );
                }
            }
        }
    });
}

1;

__END__

=head1 NAME

Plack::Middleware::ContentLength - Adds Content-Length header automatically

=head1 SYNOPSIS

  # in app.psgi

  builder {
      enable "Plack::Middleware::ContentLength";
      $app;
  }

  # Or in Plack::Handler::*
  $app = Plack::Middleware::ContentLength->wrap($app);

=head1 DESCRIPTION

Plack::Middleware::ContentLength is a middleware that automatically
adds C<Content-Length> header when it's appropriate i.e. the response
has a content body with calculable size (array of chunks or a real
filehandle).

This middleware can also be used as a library from PSGI server
implementations to automatically set C<Content-Length> rather than in
the end user level.

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

Rack::ContentLength

=cut


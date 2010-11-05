package Site::Dispatch;
use strict;
use Plack::Request;

sub new {
    my ( $class, $dispatch_table ) = @_;
    return sub {
        my $env = shift;
        
        my $req = Plack::Request->new($env);
        my $res;

        # Dispatch The Request
       
        for my $candidate ( @$dispatch_table ) {
            if ( $req->request_uri =~ $candidate->{url} ) {
                if ( not exists $candidate->{test} or $candidate->{test}( $req )  ) {
                    $res = $candidate->{call}( $req, $res );
                    last unless $candidate->{pass};
                } elsif ( exists $candidate->{test} and exists $candidate->{failcall} ) {
                    $res = $candidate->{failcall}( $req );
                    last;
                }
            }
        }
        
        if ( not defined $res ) {
            $res = $req->new_response(404);
            $res->body( "File Not Found!" );

        }
        
        if ( $req->path( ) =~ /\.(css)$/ ) {
            $res->header( 'Content-Type' => 'text/css' );
        }
        #} else {
        #    $res->header( 'Content-Type' => 'text/html' );
        #}
        $res->finalize();
    };
}
1;

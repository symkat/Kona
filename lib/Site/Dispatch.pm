package Site::Dispatch;
use strictures 1;
use Plack::Request;

my %cache;

sub new {
    my ( $class, $dispatch_table ) = @_;
    return sub {
        my $env = shift;
        
        my $req = Plack::Request->new($env);
        my $method = "handle_" . $req->method;
        my $res;

        # Dispatch The Request
       
        for my $candidate ( @$dispatch_table ) {
            if ( $req->request_uri =~ $candidate->{url} ) {
                if ( ( !exists $candidate->{test} or exists $candidate->{test} and $candidate->{test}->($req) )
                   and exists $candidate->{package} and my $this = "$candidate->{package}"->can( $method ) ) {
                    # Get Object
                    my $Obj = $cache{$candidate->{package}} ||= $candidate->{package}->new( 
                        schema => $Site::heap{schema}, 
                        config => $Site::heap{config},
                    );
                    $Obj->res( $req->new_response(200) );
                    $Obj->req( $req );

                    $res = $Obj->$method;
                    last;
                } else {
                    # URI Match, but method ( GET POST ... ) not supported by package, 405 it
                    $res = $req->new_response(405);
                    $res->body("Method Not Allowed");
                }
            }
        }
        
        if ( not defined $res ) {
            $res = $req->new_response(404);
            $res->body( "File Not Found!" );

        }
        
        if ( $req->path( ) =~ /\.(css)$/ ) {
            $res->header( 'Content-Type' => 'text/css' );
        } else {
            $res->header( 'Content-Type' => 'text/html' );
        }
        $res->finalize();
    };
}
1;

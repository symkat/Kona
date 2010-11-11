package Site::Utils;
use strictures 1;
use Template;

require Exporter;
our @ISA = qw/ Exporter /;
our @EXPORT = qw/ get_request_info get_template http_method_not_allowed /;


my $template = Template->new(
    {
        INCLUDE_PATH =>'templates/',
        WRAPPER => 'wrapper.tt2',
        INTERPOLATE => 0,
        POST_CHOMP => 1,
        EVAL_PERL => 1,
    },
);

sub get_request_info {
    my ( $req ) = @_;

    my $res = $req->new_response(200);
    my $con = $req->method();
    my $uri = URI->new($req->request_uri());
   
    return ( $res, $con, $uri );
}

sub get_template {
    return $template;
}

###### HTTP Request Helpers

sub http_method_not_allowed {
    my ( $res ) = @_;
    $res->status(405);
    $res->body( "Method Not Allowed" );
    return $res;
}






1;

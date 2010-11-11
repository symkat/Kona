package Site::Config;
use strictures 1;
use YAML;
use Carp;

sub load_config {
    my ( $class, $filename ) = @_;
    my $self = {};
    bless $self, $class;
    $self->{config_file} = ( defined $filename ? $filename : 'conf/conf.yaml' );
    
    my $yml = YAML::LoadFile( $self->{config_file} )
        or die "Failed to load YAML file for reading: $!";
    
    return $self->is_valid( $yml );
}

sub is_valid {
    my ( $self, $yml ) = @_;

    confess "Config File Malformed" unless ( ref $yml );
   
    ### Verify the DB Configuration Exists ###
    confess "Database Key Required" unless ( ref $yml->{database} ) eq 'HASH'; 
    
    confess "Database/hostname Key Required" unless ( ref \$yml->{database}->{hostname} ) eq 'SCALAR'; 
    confess "Database/username Key Required" unless ( ref \$yml->{database}->{username} ) eq 'SCALAR'; 
    confess "Database/database Key Required" unless ( ref \$yml->{database}->{database} ) eq 'SCALAR'; 
    confess "Database/password Key Required" unless ( ref \$yml->{database}->{password} ) eq 'SCALAR'; 

    confess "database/hostname must be set" unless ( $yml->{database}->{hostname} ne "" );
    confess "database/database must be set" unless ( $yml->{database}->{database} ne "" );
    confess "database/username must be set" unless ( $yml->{database}->{username} ne "" );
    confess "database/password must be set" unless ( $yml->{database}->{password} ne "" );



    return $yml;
}

1;

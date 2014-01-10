package Pagesmith::Adaptor::OA2;

## Base adaptor for objects in OA2 namespace

## Author         : James Smith <js5>
## Maintainer     : James Smith <js5>
## Created        : Tue, 07 Jan 2014
## Last commit by : $Author$
## Last modified  : $Date$
## Revision       : $Revision$
## Repository URL : $HeadURL$

use strict;
use warnings;
use utf8;

use version qw(qv); our $VERSION = qv('0.1.0');

use base qw(Pagesmith::Adaptor);
use Pagesmith::Core qw(user_info);

sub connection_pars {
#@params (self)
#@return (string)
## Returns key to database connection in configuration file
  my $self = shift;
  return q(oa2);
}

sub attach_user {
  my( $self, $user ) = @_;
  $self->set_user( $user->username );
  return $self;
}

sub get_other_adaptor {
#@params (self) (string object type)
#@return (Pagesmith::Adaptor::OA2)
## Returns a database adaptor for the given type of object.

  my( $self, $type ) = @_;
  ## Get the adaptor from the "pool of adaptors"
  ## If the adaptor doesn't exist then we well get it, and create
  ## attach it to the pool

  my $adaptor = $self->get_adaptor_from_pool( $type );
  return $adaptor || $self->get_adaptor(      "OA2::$type", $self )
                          ->set_user( $self->user )
                          ->add_self_to_pool( $type );
}

sub project_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'Project' );
}

sub user_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'User' );
}

sub client_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'Client' );
}

sub authcode_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'AuthCode' );
}

sub scope_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'Scope' );
}

sub accesstoken_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'AccessToken' );
}

sub refreshtoken_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'RefreshToken' );
}

sub url_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'Url' );
}

1;

__END__

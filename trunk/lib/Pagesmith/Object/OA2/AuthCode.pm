package Pagesmith::Object::OA2::AuthCode;

## Class for AuthCode objects in namespace OA2.

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

use base qw(Pagesmith::Object::OA2);

use Const::Fast qw(const);

## Definitions of lookup constants and methods exposing them to forms.
## ===================================================================

## uid property....
## ----------------

sub uid {
  my $self = shift;
  return $self->{'obj'}{'authcode_id'};
}

## Property get/setters
## ====================

## Property: authcode_id
## ---------------------

sub get_authcode_id {
  my $self = shift;
  return $self->{'obj'}{'authcode_id'};
}

sub set_authcode_id {
  my ( $self, $value ) = @_;
  if( $value <= 0 ) {
    warn "Trying to set non positive value for 'authcode_id'\n";
    return $self;
  }
  $self->{'obj'}{'authcode_id'} = $value;
  return $self;
}

## Property: uuid
## --------------

sub get_uuid {
  my $self = shift;
  return $self->{'obj'}{'uuid'};
}

sub set_uuid {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'uuid'} = $value;
  return $self;
}

## Property: expires_at
## --------------------

sub get_expires_at {
  my $self = shift;
  return $self->{'obj'}{'expires_at'};
}

sub set_expires_at {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'expires_at'} = $value;
  return $self;
}

## Has "1" get/setters
## ===================

sub get_user {
  my $self = shift;
  return $self->get_other_adaptor( 'User' )->fetch_user_by_auth_code( $self );
}

sub get_client {
  my $self = shift;
  return $self->get_other_adaptor( 'Client' )->fetch_client_by_auth_code( $self );
}

sub get_url {
  my $self = shift;
  return $self->get_other_adaptor( 'Url' )->fetch_url_by_auth_code( $self );
}

sub get_scope {
  my $self = shift;
  return $self->get_other_adaptor( 'Scope' )->fetch_scope_by_auth_code( $self );
}

## Has "many" getters
## ==================

## Relationship getters!
## =====================

## Store method
## =====================

sub store {
  my $self = shift;
  return $self->adaptor->store( $self );
}

## Other fetch functions!
## ======================
## Can add additional fetch functions here! probably hand crafted to get
## the full details...!

1;

__END__

Purpose
-------

Object classes are the basis of the Pagesmith OO abstraction layer



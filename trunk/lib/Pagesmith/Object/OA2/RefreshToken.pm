package Pagesmith::Object::OA2::RefreshToken;

## Class for RefreshToken objects in namespace OA2.

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
  return $self->{'obj'}{'refreshtoken_id'};
}

## Property get/setters
## ====================

## Property: refreshtoken_id
## -------------------------

sub get_refreshtoken_id {
  my $self = shift;
  return $self->{'obj'}{'refreshtoken_id'};
}

sub set_refreshtoken_id {
  my ( $self, $value ) = @_;
  if( $value <= 0 ) {
    warn "Trying to set non positive value for 'refreshtoken_id'\n";
    return $self;
  }
  $self->{'obj'}{'refreshtoken_id'} = $value;
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

sub expires_in {
  my $self = shift;
  return $self->{'obj'}{'expires_at_ts'} - time;
}

## Has "1" get/setters
## ===================

sub get_access_token {
  my $self = shift;
  return $self->get_other_adaptor( 'AccessToken' )->fetch_access_token_by_refresh_token( $self );
}

sub get_client {
  my $self = shift;
  return $self->get_other_adaptor( 'Client' )->fetch_client_by_refresh_token( $self );
}

sub get_user {
  my $self = shift;
  return $self->get_other_adaptor( 'User' )->fetch_user_by_refresh_token( $self );
}

## Has "many" getters
## ==================

sub get_all_scopes {
  my $self = shift;
  return $self->get_other_adaptor( 'Scope' )->fetch_all_scopes_by_refresh_token( $self );
}

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

sub add_scope {
  my( $self, $scope ) = @_;
  $self->fetch_scopes unless exists $self->{'scopes'};
  my $scope_uid = ref $scope ? $scope->uid : $scope;
  unless( $self->{'scopes'}{$scope->uid} ) {
    $self->{'scopes'}{$scope->uid} = $scope;
    $self->adaptor->add_scope( $self, $scope );
  }
  return $self;
}

sub clear_scopes {
  my $self = shift;
  $self->{'scopes'} = {};
  $self->adaptor->clear_scopes( $self );
  return $self;
}

sub scopes {
  my $self = shift;
  $self->fetch_scopes unless exists $self->{'scopes'};
  return values %{$self->{'scopes'}};
}

sub scopes_ref {
  my $self = shift;
  $self->fetch_scopes unless exists $self->{'scopes'};
  return $self->{'scopes'};
}

sub fetch_scopes {
  my $self = shift;
  $self->{'scopes'} = {map { $_->uid => $_ } @{$self->scope_adaptor->fetch_scopes_by_authcode( $self )}};
  return $self;
}

sub create_accesstoken {
  my $self = shift;
 return $self->accesstoken_adaptor->create_from_refreshtoken( $self );
}

1;

__END__

Purpose
-------

Object classes are the basis of the Pagesmith OO abstraction layer


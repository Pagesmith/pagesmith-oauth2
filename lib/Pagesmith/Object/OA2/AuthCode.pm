package Pagesmith::Object::OA2::AuthCode;

#+----------------------------------------------------------------------
#| Copyright (c) 2014 Genome Research Ltd.
#| This file is part of the OAuth2 extensions to Pagesmith web
#| framework.
#+----------------------------------------------------------------------
#| The OAuth2 extensions to Pagesmith web framework is free software:
#| you can redistribute it and/or modify it under the terms of the GNU
#| Lesser General Public License as published by the Free Software
#| Foundation; either version 3 of the License, or (at your option) any
#| later version.
#|
#| This program is distributed in the hope that it will be useful, but
#| WITHOUT ANY WARRANTY; without even the implied warranty of
#| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#| Lesser General Public License for more details.
#|
#| You should have received a copy of the GNU Lesser General Public
#| License along with this program. If not, see:
#|     <http://www.gnu.org/licenses/>.
#+----------------------------------------------------------------------

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

## Property: access_type
## --------------------

sub get_access_type {
  my $self = shift;
  return $self->{'obj'}{'access_type'};
}

sub set_access_type {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'access_type'} = $value;
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

sub set_user {
  my( $self, $user ) = @_;
  $self->{'obj'}{'user_id'} = ref $user ? $user->uid : $user;
  return $self;
}

sub get_user_id {
  my $self = shift;
  return $self->{'obj'}{'user_id'}||0;
}

sub get_user {
  my $self = shift;
  return $self->get_other_adaptor( 'User' )->fetch_user( $self->get_user_id );
}

sub set_client {
  my( $self, $client ) = @_;
  $self->{'obj'}{'client_id'} = ref $client ? $client->uid : $client;
  return $self;
}

sub get_client_id {
  my $self = shift;
  return $self->{'obj'}{'client_id'}||0;
}

sub get_client {
  my $self = shift;
  return $self->get_other_adaptor( 'Client' )->fetch_client( $self->get_client_id );
}

sub set_url {
  my( $self, $url ) = @_;
  $self->{'obj'}{'url_id'} = ref $url ? $url->uid : $url;
  return $self;
}

sub get_url_id {
  my $self = shift;
  return $self->{'obj'}{'url_id'}||0;
}

sub get_url {
  my $self = shift;
  return $self->get_other_adaptor( 'Url' )->fetch_url( $self->get_url_id );
}

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

sub scopes_ref {
  my $self = shift;
  $self->fetch_scopes unless exists $self->{'scopes'};
  return $self->{'scopes'};
}

sub scopes {
  my $self = shift;
  $self->fetch_scopes unless exists $self->{'scopes'};
  return values %{$self->{'scopes'}};
}

sub fetch_scopes {
  my $self = shift;
  $self->{'scopes'} = {map { $_->uid => $_ } @{$self->scope_adaptor->fetch_scopes_by_authcode( $self )}};
  return $self;
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

sub create_accesstoken {
  my $self = shift;
  return $self->accesstoken_adaptor->create_from_authcode( $self );
}

sub create_refreshtoken {
  my $self = shift;
  return $self->refreshtoken_adaptor->create_from_authcode( $self );
}
1;

__END__

Purpose
-------

Object classes are the basis of the Pagesmith OO abstraction layer


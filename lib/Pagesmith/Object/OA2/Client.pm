package Pagesmith::Object::OA2::Client;

## Class for Client objects in namespace OA2.

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

const my $ORDERED_CLIENT_TYPE => [
  'web',
  'service',
  'installed',
];

const my $LOOKUP_CLIENT_TYPE => {
  'installed' => 'installed',
  'service' => 'service',
  'web' => 'web',
};

sub dropdown_values_client_type {
  return $ORDERED_CLIENT_TYPE;
}

## uid property....
## ----------------

sub uid {
  my $self = shift;
  return $self->{'obj'}{'client_id'};
}

## Property get/setters
## ====================

## Property: client_id
## -------------------

sub get_client_id {
  my $self = shift;
  return $self->{'obj'}{'client_id'};
}

sub set_client_id {
  my ( $self, $value ) = @_;
  if( $value <= 0 ) {
    warn "Trying to set non positive value for 'client_id'\n";
    return $self;
  }
  $self->{'obj'}{'client_id'} = $value;
  return $self;
}

sub generate_new_secret {
  my $self = shift;

  $self->{'obj'}{'secret'} = $self->safe_uuid;
  $self->{'obj'}{'code'}   = $self->safe_uuid;

  return $self;
}
## Property: code
## --------------

sub get_code {
  my $self = shift;
  return $self->{'obj'}{'code'};
}

sub set_code {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'code'} = $value;
  return $self;
}

## Property: secret
## ----------------

sub get_secret {
  my $self = shift;
  return $self->{'obj'}{'secret'};
}

sub set_secret {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'secret'} = $value;
  return $self;
}

sub set_project {
  my( $self, $project ) = @_;
  $self->dumper( $project );
  $project = $project->uid if ref $project;
  $self->{'obj'}{'project_id'} = $project;
  return $self;
}

sub get_project_id {
  my $self = shift;
  return $self->{'obj'}{'project_id'};
}

## Property: client_type
## ---------------------

sub get_client_type {
  my $self = shift;
  return $self->{'obj'}{'client_type'};
}

sub set_client_type {
  my ( $self, $value ) = @_;
  unless( exists $LOOKUP_CLIENT_TYPE->{$value} ) {
    warn "Trying to set invalid value for 'client_type'\n";
    return $self;
  }
  $self->{'obj'}{'client_type'} = $value;
  return $self;
}

## Has "1" get/setters
## ===================

sub get_project {
  my $self = shift;
  return $self->get_other_adaptor( 'Project' )->fetch_project_by_client( $self );
}

## Has "many" getters
## ==================

sub get_all_urls {
  my $self = shift;
  return $self->get_other_adaptor( 'Url' )->fetch_all_urls_by_client( $self );
}

sub add_uri {
  my( $self, $type, $uri ) = @_;
  return $self->get_other_adaptor( 'Url' )->quick_create( $self, $type, $uri );
}

## Relationship getters!
## =====================

## Store method
## =====================

sub store {
  my $self = shift;
  return $self->adaptor->store( $self );
}

sub remove {
  my $self = shift;
  return $self->adaptor->remove( $self );
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


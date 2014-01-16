package Pagesmith::Object::OA2::User;

## Class for User objects in namespace OA2.

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
  return $self->{'obj'}{'user_id'};
}

## Property get/setters
## ====================

## Property: user_id
## -----------------

sub get_user_id {
  my $self = shift;
  return $self->{'obj'}{'user_id'};
}

sub set_user_id {
  my ( $self, $value ) = @_;
  if( $value <= 0 ) {
    warn "Trying to set non positive value for 'user_id'\n";
    return $self;
  }
  $self->{'obj'}{'user_id'} = $value;
  return $self;
}

## Property: uuid
## --------------

## Property: username
## ------------------

sub get_username {
  my $self = shift;
  return $self->{'obj'}{'username'};
}

sub set_username {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'username'} = $value;
  return $self;
}

sub get_developer {
  my $self = shift;
  return $self->{'obj'}{'developer'};
}

sub is_developer {
  my $self = shift;
  return $self->{'obj'}{'developer'} eq 'yes';
}

sub set_developer {
  my ( $self, $value ) = @_;
  $value = 'no' unless 'yes' eq $value;
  $self->{'obj'}{'developer'} = $value;
  return $self;
}

## Has "1" get/setters
## ===================

## Has "many" getters
## ==================

sub get_all_projects {
  my $self = shift;
  return $self->project_adaptor->fetch_all_projects_by_user( $self );
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

1;

__END__

Purpose
-------

Object classes are the basis of the Pagesmith OO abstraction layer

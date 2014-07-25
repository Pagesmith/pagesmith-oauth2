package Pagesmith::Object::OA2::Scope;

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

## Class for Scope objects in namespace OA2.

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
  return $self->{'obj'}{'scope_id'};
}

## Property get/setters
## ====================

## Property: scope_id
## ------------------

sub get_scope_id {
  my $self = shift;
  return $self->{'obj'}{'scope_id'};
}

sub set_scope_id {
  my ( $self, $value ) = @_;
  if( $value <= 0 ) {
    warn "Trying to set non positive value for 'scope_id'\n";
    return $self;
  }
  $self->{'obj'}{'scope_id'} = $value;
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

## Property: name
## --------------

sub get_name {
  my $self = shift;
  return $self->{'obj'}{'name'};
}

sub set_name {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'name'} = $value;
  return $self;
}

## Property: description
## ---------------------

sub get_description {
  my $self = shift;
  return $self->{'obj'}{'description'};
}

sub set_description {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'description'} = $value;
  return $self;
}

## Has "1" get/setters
## ===================

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


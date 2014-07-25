package Pagesmith::Adaptor::OA2::Scope;

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

## Adaptor for objects of type Scope in namespace OA2

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

use Const::Fast qw(const);

## no critic (ImplicitNewlines)

const my $FULL_COLNAMES  =>
          'o.scope_id, o.code, o.name, o.description';

const my $AUDIT_COLNAMES => q();

const my $TABLE_COLNAMES => {
};

const my $TABLE_TABLES => {
};

use base qw(Pagesmith::Adaptor::OA2);
use Pagesmith::Object::OA2::Scope;
## Store/update functionality perl
## ===============================

sub store {
#@params (self) (Pagesmith::Object::OA2::Scope object)
#@return (boolean)
## Store object in database
  my( $self, $my_object ) = @_;
  ## Check that the user has permission to write back to the db ##
  return $self->_update( $my_object ) if $my_object->uid;
  return $self->_store(  $my_object ); ## Now we perform the access options ##
}

sub _store {
#@params (self) (Pagesmith::Object::OA2::Scope object)
#@return (boolean)
## Create a new entry in database
}

sub _update {
#@params (self) (Pagesmith::Object::OA2::Scope object)
#@return (boolean)
## Create a new entry in database
}


## Support methods to bless SQL hash & create empty objects...
## -----------------------------------------------------------

sub make_scope {
#@params (self), (string{} properties), (int partial)?
#@return (Pagesmith::Object::OA2::Scope)
## Take a hashref (usually retrieved from the results of an SQL query) and create a new
## object from it.
  my( $self, $hashref, $partial ) = @_;
  return Pagesmith::Object::OA2::Scope->new( $self, $hashref, $partial );
}

sub create {
#@params (self)
#@return (Pagesmith::Object::OA2::Scope)
## Create an empty object
  ## Check that the user has permission to write back to the db ##
  my $self = shift;
  return $self->make_scope({});
}

## Fetch methods..
## ===============

## Fetch all/one
## -------------

sub fetch_scopes {
#@params (self)
#@return (Pagesmith::Object::OA2::Scope)*
## Return all objects from database!
  my $self = shift;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from scope o
     order by scope_id";
  my $scopes = [ map { $self->make_scope( $_ ) }
               @{$self->all_hash( $sql )||[]} ];
  return $scopes;
}

sub fetch_scopes_by_authcode {
#@params (self)
#@return (Pagesmith::Object::OA2::Scope)*
## Return all objects from database!
  my( $self, $auth_code ) = @_;
  $auth_code = ref $auth_code ? $auth_code->uid : $auth_code;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from scope o, authcode_scope as acs
     where o.scope_id = acs.scope_id and acs.authcode_id = ?
     order by o.scope_id";
  my $scopes = [ map { $self->make_scope( $_ ) }
               @{$self->all_hash( $sql, $auth_code )||[]} ];
  return $scopes;
}

sub fetch_scope {
#@params (self)
#@return (Pagesmith::Object::OA2::Scope)?
## Return objects from database with given uid!
  my( $self, $uid ) = @_;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from scope o
    where o.scope_id = ?";
  my $scope_hashref = $self->row_hash( $sql, $uid );
  return unless $scope_hashref;
  my $scope = $self->make_scope( $scope_hashref );
  return $scope;
}

## Fetch by relationships
## ----------------------

## use critic

1;

__END__

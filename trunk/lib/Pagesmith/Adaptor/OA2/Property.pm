package Pagesmith::Adaptor::OA2::Property;

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

## Adaptor for relationship Property in namespace OA2

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

use base qw(Pagesmith::Adaptor::OA2);

use Const::Fast qw(const);
## no critic (ImplicitNewlines)

const my $DATA_COLUMNS => q(,
           rel.value);

## ----------------------------------------------------------------------
## Store and update methods
## ----------------------------------------------------------------------

sub store {
#@params (self) ()
#@return (boolean)
## Store value of relationship in database
  my( $self, $pars ) = @_;

  my $sql = '
    insert ignore into property
         ( value,
           user_id,
           scope_id )
  values ( ?,?,? )';

  $self->query( $sql,$params->{'value'},
           exists $params->{'user_id'} ? $params->{'user_id'} : $params->{'user'}->user_id,
           exists $params->{'scope_id'} ? $params->{'scope_id'} : $params->{'scope'}->scope_id,
  );
  return $self->update( $pars );
}

sub update {
#@params (self) (hash)
#@return (boolean)
## Store value of relationship in database
  my( $self, $pars ) = @_;

  my $sql = '
    update property
       set value = ?
     where user_id = ?,
           scope_id = ?';

  return $self->query( $sql,$params->{'value'},
           exists $params->{'user_id'} ? $params->{'user_id'} : $params->{'user'}->user_id,
           exists $params->{'scope_id'} ? $params->{'scope_id'} : $params->{'scope'}->scope_id,
  );
}

## ----------------------------------------------------------------------
## Fetch methods
## ----------------------------------------------------------------------

sub get_property {
#@param (self)
#@param (Pagesmith::Adaptor::OA2::User|integer) user
#@param (Pagesmith::Adaptor::OA2::Scope|integer) scope
#@returns (hash)?
## Fetch single row from database
  my( $self, $user, $scope )  = @_;
  my $sql = '
    select ? as user_id,
           ? as scope_id'.$DATA_COLUMNS.'
      from property as rel
     where rel.user_id=?,
           rel.scope_id=?';
  return $self->hash( $sql,
    ref $user ? $user->id : $user,
    ref $scope ? $scope->id : $scope,
    $user->id,
    $scope->id );
}

sub get_all_property {
#@param (self)
#@returns (hash[])
## Fetch arrayref of rows from database
  my( $self )  = @_;
  my $sql = '
    select rel.user_id,
           rel.scope_id'.$DATA_COLUMNS.'
      from property as rel, user, scope
     where rel.user_id=user.user_id,
           rel.scope_id=scope.scope_id';
  return $self->all_hash( $sql )||[];
}

## use critic

1;

__END__

Purpose
-------

Relationship adaptors like this represent relationships between core objects
(without themselves being objects). Many pairs of objects may have multiple
relationships between them.


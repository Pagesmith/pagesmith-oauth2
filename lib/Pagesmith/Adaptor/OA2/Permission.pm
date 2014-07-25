package Pagesmith::Adaptor::OA2::Permission;

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

## Adaptor for relationship Permission in namespace OA2

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

const my $DATA_COLUMNS => q(, rel.status);

## ----------------------------------------------------------------------
## Store and update methods
## ----------------------------------------------------------------------

sub store {
#@params (self) ()
#@return (boolean)
## Store value of relationship in database
  my( $self, $params ) = @_;

  my $sql = '
    insert ignore into permission
         ( user_id,
           project_id,
           scope_id )
  values ( ?,?,? )';

  $self->query( $sql,
    ref $params->{'user'}    ? $params->{'user'}->uid    : $params->{'user'},
    ref $params->{'project'} ? $params->{'project'}->uid : $params->{'project'},
    ref $params->{'scope'}   ? $params->{'scope'}->uid   : $params->{'scope'},
  );
  return $self->update( $params );

}

sub update {
#@params (self) (hash)
#@return (boolean)
## Store value of relationship in database
  my( $self, $params ) = @_;

  my $sql = '
    update permission
       set status = ?
     where user_id    = ? and
           project_id = ? and
           scope_id   = ?';

  return $self->query( $sql,
    exists $params->{'status'} && $params->{'status'} eq 'refused' ? 'refused' : 'granted',
    ref $params->{'user'}    ? $params->{'user'}->uid    : $params->{'user'},
    ref $params->{'project'} ? $params->{'project'}->uid : $params->{'project'},
    ref $params->{'scope'}   ? $params->{'scope'}->uid   : $params->{'scope'},
  );
}

## ----------------------------------------------------------------------
## Fetch methods
## ----------------------------------------------------------------------

sub get_permission {
#@param (self)
#@param (Pagesmith::Adaptor::OA2::User|integer) user
#@param (Pagesmith::Adaptor::OA2::Project|integer) project
#@param (Pagesmith::Adaptor::OA2::Scope|integer) scope
#@returns (hash)?
## Fetch single row from database
  my( $self, $user, $project, $scope )  = @_;
  my $sql = '
    select ? as user_id,
           ? as project_id, ? as project_name,
           ? as scope_id, s.code'.$DATA_COLUMNS.'
      from permission as rel
     where rel.user_id=?    and
           rel.project_id=? and
           rel.scope_id=?';
  return $self->row_hash( $sql,
    ref $user    ? $user->uid         : $user,
    ref $project ? $project->uid      : $project,
    ref $project ? $project->get_name : q(-),
    ref $scope   ? $scope->uid        : $scope,
    ref $scope   ? $scope->get_code   : q(-),
    ref $user    ? $user->uid         : $user,
    ref $project ? $project->uid      : $project,
    ref $scope   ? $scope->uid        : $scope );
}

sub get_permissions_by_user_project {
#@param (self)
#@param (Pagesmith::Adaptor::OA2::User|integer) user
#@param (Pagesmith::Adaptor::OA2::Project|integer) project
#@returns (hash)?
## Fetch single row from database
  my( $self, $user, $project )  = @_;
  my $sql = '
    select ? as user_id,
           ? as project_id, ? as project_name,
           rel.scope_id, s.code'.$DATA_COLUMNS.'
      from permission as rel, scope s
     where rel.user_id=? and rel.scope_id = s.scope_id and
           rel.project_id=?';
  return $self->all_hash( $sql,
    ref $user    ? $user->uid         : $user,
    ref $project ? $project->uid      : $project,
    ref $project ? $project->get_name : q(-),
    ref $user    ? $user->uid         : $user,
    ref $project ? $project->uid      : $project,
  );
}

sub get_all_permission {
#@param (self)
#@returns (hash[])
## Fetch arrayref of rows from database
  my( $self )  = @_;
  my $sql = '
    select rel.user_id,
           rel.project_id,
           project.name as project_name,
           rel.scope_id, s.code'.$DATA_COLUMNS.'
      from permission as rel, user, project, scope
     where rel.user_id=user.user_id and
           rel.project_id=project.project_id and
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


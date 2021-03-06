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

## Adaptor for objects of type Permission in namespace OA2

## Author         : James Smith <js5@sanger.ac.uk>
## Maintainer     : James Smith <js5@sanger.ac.uk>
## Created        : 30th Jul 2014

## Last commit by : $Author$
## Last modified  : $Date$
## Revision       : $Revision$
## Repository URL : $HeadURL$

use strict;
use warnings;
use utf8;

use version qw(qv); our $VERSION = qv('0.1.0');

use base qw(Pagesmith::Adaptor::OA2);
use Pagesmith::Utils::ObjectCreator qw(bake);

## Last bit - bake all remaining methods!

sub fetch_permissions_by_user_project {
  my( $self, $user, $project ) = @_;

  return $self->all_hash(
    'select ? as user_id, ? as project_id, ? as project_name,
            rel.scope_id, s.code, rel.allowed
       from permission as rel, scope s
      where rel.project_id = ? and rel.user_id = ? and rel.scope_id = s.scope_id',
    $user->uid, $project->uid, $project->get_name,
    $project->uid, $user->uid );
}

sub add_permission {
  my ($self, $user, $project, $scope, $flag ) = @_;
  return $self->query( 'insert ignore into permission (user_id, project_id, scope_id, allowed )
                          values (?,?,?,?)',
                       $user->uid, $project->uid, $scope->uid, $flag );
}

sub revoke {
  my( $self, $project, $user ) = @_;
  return $self->query( 'delete from permission where project_id = ? and user_id = ?', $project->uid, $user->uid );
}

bake();

1;

__END__

Purpose
-------

Adaptor classes interface with databases as the basis of the Pagesmith OO abstraction layer

Notes
=====

What methods do I have available to me...!
------------------------------------------

This is an auto generated module. You can get a list of the auto
generated methods by calling the "auto generated"
__PACKAGE__->auto_methods or $obj->auto_methods!

Overriding methods
------------------

If you override an auto-generated method a version prefixed with
std_ will be generated which you can use within the package. e.g.

sub store {
  my( $self, $o ) = @_;
  warn 'Storing '.$o->get_code,"\n";
  return $self->std_store( $o );     ## Call the standard method!
}


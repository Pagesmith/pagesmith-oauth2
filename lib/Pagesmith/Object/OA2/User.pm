package Pagesmith::Object::OA2::User;

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

use base qw(Pagesmith::Object::OA2);
use Pagesmith::Utils::ObjectCreator qw(bake);

## Last bit - bake all remaining methods!
bake();

1;

## no critic (Many Args LongChainsOfMethodCalls)
sub create_auth_code {
  my ( $self, $client, $url_obj, $access_type, $session_key, $authmethod ) = @_;
  my $ac_obj = $self->get_other_adaptor( 'AuthCode' )->create
    ->set_user(   $self )
    ->set_client( $client )
    ->set_url(    $url_obj )
    ->set_access_type( $access_type )
    ->set_session_key( $session_key );
  $ac_obj->set_expires_at( $ac_obj->adaptor->offset( 1, 'month' ) );
  $ac_obj->store;
  return $ac_obj;
}
## use critic
sub add_permission {
  my( $self, $project, $scope, $flag ) = @_;
  return $self->get_other_adaptor( 'Permission' )->add_permission( $self, $project, $scope, $flag );
}
sub get_permissions {
  my( $self, $project ) = @_;
  return $self->get_other_adaptor( 'Permission' )->fetch_permissions_by_user_project( $self, $project );
}
sub fetch_projects {
  my $self = shift;
  return $self->get_other_adaptor( 'Project' )->fetch_projects_by_user( $self );
}

sub fetch_accesstokens {
  my $self = shift;
  return $self->get_other_adaptor( 'AccessToken' )->fetch_accesstokens_by_user( $self );
}

sub fetch_refreshtokens {
  my $self = shift;
  return $self->get_other_adaptor( 'RefreshToken' )->fetch_refreshtokens_by_user( $self );
}

1;

__END__

Purpose
=======

Object classes are the basis of the Pagesmith OO abstraction layer

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

sub get_name {
  my $self = shift;
  my $name = $self->std_get_name;
  $name = 'Sir, '.$name;
  return $name;
}


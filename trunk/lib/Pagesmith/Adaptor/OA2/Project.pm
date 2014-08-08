package Pagesmith::Adaptor::OA2::Project;

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

## Adaptor for objects of type Project in namespace OA2

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
bake();

sub fetch_permitted_projects {
  my ($self,$user) = @_;
  my $user_id = defined $user ? ( ref $user ? $user->uid : $user ) : $self->user_id;
  my $res = $self->all_hash( '
     select '.$self->full_column_names.$self->audit_column_names.', perm.scope_id, perm.allowed
       from '.$self->select_tables.', permission perm
      where o.project_id = perm.project_id and perm.user_id = ?',
     $user_id );
  my $objs = {};
  foreach (@{$res}) {
    $objs->{ $_->{'project_id'} } ||= [ $self->make_project($_), {} ];
    $objs->{ $_->{'project_id'} }[1]{ $_->{'scope_id'} } = $_->{'allowed'};
  }
  my @return;
  foreach ( values $objs ) {
    $_->[0]->set_attribute( 'scopes', $_->[1] );
    push @return, $_->[0];
  }
  return \@return;
}

sub get_image {
  my( $self, $my_object ) = @_;
  return $self->row_hash( 'select logo_width, logo_height, logo_blob
                             from project where project_id = ?', $my_object->uid );
}

sub store {
  my ($self,$my_object) = @_;
  my $flag = $self->std_store($my_object);
  $my_object->store_image if $flag;
  return $flag;
}

sub store_image {
  my ($self, $my_object, $width, $height, $compressed_image ) = @_;
  return $self->query( 'update project set logo_width = ?, logo_height = ?, logo_blob = ? where project_id = ?',
    $width, $height, $compressed_image, $my_object->uid );
}

sub revoke {
  my( $self, $project, $user ) = @_;
  return
    $self->query(
      'delete authcode, authcode_scope from authcode, authcode_scope, client
        where client.project_id = ? and authcode.client_id = client.client_id and authcode.user_id = ? and
              authcode.authcode_id = authcode_scope.authcode_id',
        $project->uid, $user->uid,
    ) +
    $self->query(
      'delete accesstoken, accesstoken_scope from accesstoken, accesstoken_scope, client
        where client.project_id = ? and accesstoken.client_id = client.client_id and accesstoken.user_id = ? and
              accesstoken.accesstoken_id = accesstoken_scope.accesstoken_id',
        $project->uid, $user->uid,
    ) +
    $self->query(
      'delete refreshtoken, refreshtoken_scope from refreshtoken, client, refreshtoken_scope
        where client.project_id = ? and refreshtoken.client_id = client.client_id and refreshtoken.user_id = ? and
              refreshtoken.refreshtoken_id = refreshtoken_scope.refreshtoken_id',
        $project->uid, $user->uid,
    );
}


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


package Pagesmith::Adaptor::OA2::RefreshToken;

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

## Adaptor for objects of type RefreshToken in namespace OA2

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

use Const::Fast qw(const);
const my $DAYS => 180;

use base qw(Pagesmith::Adaptor::OA2);
use Pagesmith::Utils::ObjectCreator qw(bake);

## Last bit - bake all remaining methods!

sub create_from_authcode {
  my( $self, $authcode )  = @_;
  my ($ts,$ts_unix) = $self->offset( $DAYS,'day' );
  my $token = $self->make_refreshtoken( {
    'client_id'       => $authcode->get_client_id,
    'user_id'         => $authcode->get_user_id,
    'scopes'          => $authcode->scopes_ref,
    'expires_at'      => $ts,
    'expires_at_ts'   => $ts_unix,
    'session_key'     => $authcode->get_session_key,
  });
  $token->store;
  $self->query( 'insert ignore into refreshtoken_scope select ?,scope_id from authcode_scope where authcode_id = ?',
    $token->uid, $authcode->uid );
  return $token;

}

sub clear_scopes {
  my ( $self, $auth_code ) = @_;
  return $self->query( 'delete from refreshtoken_scope where authcode_id = ?', $auth_code->uid );
}

sub add_scope {
  my ( $self, $auth_code, $scope ) = @_;
  return $self->query( 'insert ignore into refreshtoken_scope (authcode_id,scope_id) values(?,?)', $auth_code->uid, $scope->uid );
}

sub revoke {
  my( $self, $refreshtoken, $user ) = @_;
  return
    $self->query(
      'delete accesstoken_scope, accesstoken from accesstoken, accesstoken_scope
        where accesstoken.user_id = ? and accesstoken.refreshtoken_id = ? and accesstoken.accesstoken_id = accesstoken_scope.accesstoken_id',
      $user->uid, $refreshtoken->uid ) +
     $self->query(
      'delete refreshtoken_scope, refreshtoken from accesstoken, accesstoken_scope
        where refreshtoken.user_id = ? and refreshtoken.refreshtoken_id = ? and refreshtoken.refreshtoken_id = refreshtoken_scope.refreshtoken_id
        where refreshtoken_id = ? and user_id = ?',
      $user->uid, $refreshtoken->uid );
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


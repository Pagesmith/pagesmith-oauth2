package Pagesmith::Adaptor::OA2::AuthCode;

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

## Adaptor for objects of type AuthCode in namespace OA2

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
const my $HOUR => 3_600;

## no critic (ImplicitNewlines)

const my $FULL_COLNAMES  =>
          'o.authcode_id, o.access_type,  o.uuid, unix_timestamp(o.expires_at) as expires_at_ts, o.expires_at, o.user_id, o.client_id,o.url_id';

const my $AUDIT_COLNAMES => q();

const my $TABLE_COLNAMES => {
};

const my $TABLE_TABLES => {
};

use base qw(Pagesmith::Adaptor::OA2);
use Pagesmith::Object::OA2::AuthCode;
## Store/update functionality perl
## ===============================

sub store {
#@params (self) (Pagesmith::Object::OA2::AuthCode object)
#@return (boolean)
## Store object in database
  my( $self, $my_object ) = @_;
  ## Check that the user has permission to write back to the db ##
  return $self->_update( $my_object ) if $my_object->uid;
  return $self->_store(  $my_object ); ## Now we perform the access options ##
}

sub _store {
#@params (self) (Pagesmith::Object::OA2::AuthCode object)
#@return (boolean)
## Create a new entry in database
  my( $self, $my_object ) = @_;
  my $ac_id = $self->insert( 'insert into authcode (uuid, expires_at, user_id, client_id, url_id, access_type)
                              values (?,?,?,?,?,?)', 'authcode', 'authcode_id',
    $my_object->get_uuid,
    $my_object->get_expires_at,
    $my_object->get_user_id,
    $my_object->get_client_id,
    $my_object->get_url_id,
    $my_object->get_access_type,
  );
  $my_object->set_authcode_id( $ac_id );
  return $ac_id;
}

sub _update {
#@params (self) (Pagesmith::Object::OA2::AuthCode object)
#@return (boolean)
## Create a new entry in database
}


## Support methods to bless SQL hash & create empty objects...
## -----------------------------------------------------------

sub make_auth_code {
#@params (self), (string{} properties), (int partial)?
#@return (Pagesmith::Object::OA2::AuthCode)
## Take a hashref (usually retrieved from the results of an SQL query) and create a new
## object from it.
  my( $self, $hashref, $partial ) = @_;
  my $ac = Pagesmith::Object::OA2::AuthCode->new( $self, $hashref, $partial );
  return $ac;
}

sub create {
#@params (self)
#@return (Pagesmith::Object::OA2::AuthCode)
## Create an empty object
  ## Check that the user has permission to write back to the db ##
  my $self = shift;
  my ($ts,$ts_unix) = $self->offset(1,'hour');
  return $self->make_auth_code({'uuid'=>$self->safe_uuid,'scopes'=>{},'access_type'=>'online','expires_at'=>$ts,'expires_at_ts'=>$ts_unix });
}

## Fetch methods..
## ===============

## Fetch all/one
## -------------

sub fetch_auth_codes {
#@params (self)
#@return (Pagesmith::Object::OA2::AuthCode)*
## Return all objects from database!
  my $self = shift;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from authcode o
     where expires_at > now(),
     order by authcode_id";
  my $auth_codes = [ map { $self->make_auth_code( $_ ) }
               @{$self->all_hash( $sql )||[]} ];
  return $auth_codes;
}

sub fetch_auth_code {
#@params (self)
#@return (Pagesmith::Object::OA2::AuthCode)?
## Return objects from database with given uid!
  my( $self, $uid ) = @_;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from authcode o
    where o.authcode_id = ? and expires_at > now()";
  my $auth_code_hashref = $self->row_hash( $sql, $uid );
  return unless $auth_code_hashref;
  my $auth_code = $self->make_auth_code( $auth_code_hashref );
  return $auth_code;
}

sub fetch_auth_code_by_uuid {
#@params (self)
#@return (Pagesmith::Object::OA2::AuthCode)?
## Return objects from database with given uid!
  my( $self, $code ) = @_;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from authcode o
    where o.uuid = ? and expires_at > now()";
  my $auth_code_hashref = $self->row_hash( $sql, $code );
  return unless $auth_code_hashref;
  my $auth_code = $self->make_auth_code( $auth_code_hashref );
  return $auth_code;
}

## Fetch by relationships
## ----------------------

sub clear_scopes {
  my ( $self, $auth_code ) = @_;
  $auth_code = ref $auth_code ? $auth_code->uid : $auth_code;
  return $self->query( 'delete from authcode_scope where authcode_id = ?', $auth_code );
}

sub add_scope {
  my ( $self, $auth_code, $scope ) = @_;
  $auth_code = ref $auth_code ? $auth_code->uid : $auth_code;
  $scope     = ref $scope     ? $scope->uid     : $scope;
  return $self->query( 'insert ignore into authcode_scope (authcode_id,scope_id) values(?,?)', $auth_code, $scope );
}
## use critic

1;

__END__

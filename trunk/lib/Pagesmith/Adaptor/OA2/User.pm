package Pagesmith::Adaptor::OA2::User;

## Adaptor for objects of type User in namespace OA2

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
          'o.user_id, o.uuid, o.username, o.developer, o.name, o.auth_method';

const my $AUDIT_COLNAMES => q(, o.created_at, o.updated_at, o.created_by, o.updated_by, o.ip, o.useragent);

const my $TABLE_COLNAMES => {
};

const my $TABLE_TABLES => {
};

use base qw(Pagesmith::Adaptor::OA2);
use Pagesmith::Object::OA2::User;
## Store/update functionality perl
## ===============================

sub store {
#@params (self) (Pagesmith::Object::OA2::User object)
#@return (boolean)
## Store object in database
  my( $self, $my_object ) = @_;
  ## Check that the user has permission to write back to the db ##
  return $self->_update( $my_object ) if $my_object->uid;
  return $self->_store(  $my_object ); ## Now we perform the access options ##
}

sub _store {
#@params (self) (Pagesmith::Object::OA2::User object)
#@return (boolean)
## Create a new entry in database
  my ($self, $my_object ) = @_;
  my $uid = $self->insert( 'insert into user (username,uuid,created_at,created_by,developer,name,auth_method)
                           values (?,?,?,?,?,?,?)', 'user', 'user_id',
     $my_object->get_username, $my_object->get_uuid, $my_object->now,
     $self->user, $my_object->get_developer, $my_object->get_name, $my_object->get_auth_method );
  $my_object->set_user_id( $uid );
  return $uid;
}

sub _update {
#@params (self) (Pagesmith::Object::OA2::User object)
#@return (boolean)
## Create a new entry in database
  my ($self, $my_object ) = @_;
  return $self->query( 'update user set username = ?, updated_at = ?, updated_by = ?, developer = ?, name = ?, auth_method = ?
                  where user_id = ?',
     $my_object->get_username, $my_object->now, $self->user, $my_object->get_developer, $my_object->get_name, $my_object->get_auth_method,
     $my_object->get_user_id );
}


## Support methods to bless SQL hash & create empty objects...
## -----------------------------------------------------------

sub make_user {
#@params (self), (string{} properties), (int partial)?
#@return (Pagesmith::Object::OA2::User)
## Take a hashref (usually retrieved from the results of an SQL query) and create a new
## object from it.
  my( $self, $hashref, $partial ) = @_;
  return Pagesmith::Object::OA2::User->new( $self, $hashref, $partial );
}

sub create {
#@params (self)
#@return (Pagesmith::Object::OA2::User)
## Create an empty object
  ## Check that the user has permission to write back to the db ##
  my $self = shift;
  return $self->make_user({'uuid'=>$self->safe_uuid,'developer'=>'no'});
}

## Fetch methods..
## ===============

## Fetch all/one
## -------------

sub fetch_users {
#@params (self)
#@return (Pagesmith::Object::OA2::User)*
## Return all objects from database!
  my $self = shift;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from user o
     order by user_id";
  my $users = [ map { $self->make_user( $_ ) }
               @{$self->all_hash( $sql )||[]} ];
  return $users;
}

sub fetch_user {
#@params (self)
#@return (Pagesmith::Object::OA2::User)?
## Return objects from database with given uid!
  my( $self, $uid ) = @_;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from user o
    where o.user_id = ?";
  my $user_hashref = $self->row_hash( $sql, $uid );
  return unless $user_hashref;
  my $user = $self->make_user( $user_hashref );
  return $user;
}

sub fetch_user_by_username {
#@params (self)
#@return (Pagesmith::Object::OA2::User)?
## Return objects from database with given uid!
  my( $self, $username ) = @_;
  $username ||= $self->user;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from user o
    where o.username = ?";
  my $user_hashref = $self->row_hash( $sql, $username );
  return unless $user_hashref;
  return $self->make_user( $user_hashref );
}

## Fetch by relationships
## ----------------------

## use critic

1;

__END__

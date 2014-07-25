package Pagesmith::Adaptor::OA2::Client;

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

## Adaptor for objects of type Client in namespace OA2

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
          'o.client_id, o.code, o.secret, o.client_type, o.project_id';

const my $AUDIT_COLNAMES => q(, o.created_at, o.updated_at, o.created_by, o.updated_by, o.ip, o.useragent);

const my $TABLE_COLNAMES => {
};

const my $TABLE_TABLES => {
};

use base qw(Pagesmith::Adaptor::OA2);
use Pagesmith::Object::OA2::Client;
## Store/update functionality perl
## ===============================

sub store {
#@params (self) (Pagesmith::Object::OA2::Client object)
#@return (boolean)
## Store object in database
  my( $self, $my_object ) = @_;
  ## Check that the user has permission to write back to the db ##
  return $self->_update( $my_object ) if $my_object->uid;
  return $self->_store(  $my_object ); ## Now we perform the access options ##
}

sub _store {
#@params (self) (Pagesmith::Object::OA2::Client object)
#@return (boolean)
## Create a new entry in database
  my ($self, $my_object ) = @_;
  my $uid = $self->insert( 'insert into client (
                          code,     secret,   project_id, client_type,
                          created_at, created_by)
                           values (?,?,?,?,?,?)', 'client', 'client_id',
     $my_object->get_code,          $my_object->get_secret, $my_object->get_project_id,
     $my_object->get_client_type,   $self->now,                  $self->user );
  $my_object->set_client_id( $uid );
  return $uid;

}

sub _update {
#@params (self) (Pagesmith::Object::OA2::Client object)
#@return (boolean)
## Create a new entry in database
  my ($self, $my_object ) = @_;
  return $self->query( 'update client set
                               code = ?,     secret = ?, client_type = ?,
                               updated_at = ?, updated_by = ?
                         where client_id = ?',
     $my_object->get_code,    $my_object->get_secret, $my_object->get_client_type,
     $self->now,                  $self->user,
     $my_object->get_client_id );

}

## Support methods to bless SQL hash & create empty objects...
## -----------------------------------------------------------

sub make_client {
#@params (self), (string{} properties), (int partial)?
#@return (Pagesmith::Object::OA2::Client)
## Take a hashref (usually retrieved from the results of an SQL query) and create a new
## object from it.
  my( $self, $hashref, $partial ) = @_;
  $hashref||={};
  return Pagesmith::Object::OA2::Client->new( $self, $hashref, $partial );
}

sub create {
#@params (self)
#@return (Pagesmith::Object::OA2::Client)
## Create an empty object
  ## Check that the user has permission to write back to the db ##
  my $self = shift;
  return $self->make_client->generate_new_secret;
}

## Fetch methods..
## ===============

## Fetch all/one
## -------------

sub fetch_clients {
#@params (self)
#@return (Pagesmith::Object::OA2::Client)*
## Return all objects from database!
  my $self = shift;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from client o
     order by client_id";
  my $clients = [ map { $self->make_client( $_ ) }
               @{$self->all_hash( $sql )||[]} ];
  return $clients;
}

sub fetch_all_clients_by_project {
#@params (self)
#@return (Pagesmith::Object::OA2::Client)*
## Return all objects from database!
  my ( $self, $project ) = @_;
  $project = $project->uid if ref $project;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from client o
     where o.project_id = ?
     order by client_id";
  my $clients = [ map { $self->make_client( $_ ) }
               @{$self->all_hash( $sql, $project )||[]} ];
  return $clients;
}

sub fetch_client {
#@params (self)
#@return (Pagesmith::Object::OA2::Client)?
## Return objects from database with given uid!
  my( $self, $uid ) = @_;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from client o
    where o.client_id = ?";
  my $client_hashref = $self->row_hash( $sql, $uid );
  return unless $client_hashref;
  my $client = $self->make_client( $client_hashref );
  return $client;
}

sub fetch_client_by_code {
#@params (self)
#@return (Pagesmith::Object::OA2::Client)?
## Return objects from database with given uid!
  my( $self, $code ) = @_;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from client o
    where o.code = ?";
  my $client_hashref = $self->row_hash( $sql, $code );
  return unless $client_hashref;
  my $client = $self->make_client( $client_hashref );
  return $client;
}

## Fetch by relationships
## ----------------------

## use critic

1;


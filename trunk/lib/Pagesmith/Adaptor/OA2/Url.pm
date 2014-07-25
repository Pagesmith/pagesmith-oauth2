package Pagesmith::Adaptor::OA2::Url;

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

## Adaptor for objects of type Url in namespace OA2

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
          'o.url_id, o.url_type, o.uri, o.client_id';

const my $AUDIT_COLNAMES => q(, o.created_at, o.updated_at, o.created_by, o.updated_by, o.ip, o.useragent);

const my $TABLE_COLNAMES => {
};

const my $TABLE_TABLES => {
};

use base qw(Pagesmith::Adaptor::OA2);
use Pagesmith::Object::OA2::Url;
## Store/update functionality perl
## ===============================

sub remove {
  my( $self, $my_object ) = @_;
  return $self->query( 'delete from url where url_id = ?', $my_object->uid );
}

sub store {
#@params (self) (Pagesmith::Object::OA2::Url object)
#@return (boolean)
## Store object in database
  my( $self, $my_object ) = @_;
  ## Check that the user has permission to write back to the db ##

  return $self->_update( $my_object ) if $my_object->uid;
  return $self->_store(  $my_object ); ## Now we perform the access options ##
}

sub _store {
#@params (self) (Pagesmith::Object::OA2::Url object)
#@return (boolean)
## Create a new entry in database
  my( $self, $my_object ) = @_;
  my $uid = $self->insert( 'insert into url (url_type,uri,client_id,created_at,created_by) values (?,?,?,?,?)',
    'url', 'url_id',
    $my_object->get_url_type, $my_object->get_uri, $my_object->get_client_id, $self->now, $self->user );
  return unless $uid;
  $my_object->set_url_id( $uid );
  return $uid;
}

sub _update {
#@params (self) (Pagesmith::Object::OA2::Url object)
#@return (boolean)
## Create a new entry in database
  my( $self, $my_object ) = @_;
  return $self->query( 'update url set url_type = ?, uri = ?, client_id = ?, updated_at = ?, updated_by = ? where url_id = ?',
    $my_object->get_url_type, $my_object->get_uri, $my_object->get_client_id,
    $self->now, $self->user, $my_object->uid );
}


## Support methods to bless SQL hash & create empty objects...
## -----------------------------------------------------------

sub make_url {
#@params (self), (string{} properties), (int partial)?
#@return (Pagesmith::Object::OA2::Url)
## Take a hashref (usually retrieved from the results of an SQL query) and create a new
## object from it.
  my( $self, $hashref, $partial ) = @_;
  return Pagesmith::Object::OA2::Url->new( $self, $hashref, $partial );
}

sub create {
#@params (self)
#@return (Pagesmith::Object::OA2::Url)
## Create an empty object
  ## Check that the user has permission to write back to the db ##
  my $self = shift;
  return $self->make_url({});
}

sub quick_create {
  my( $self, $client, $type, $uri ) = @_;
  return $self->create
       ->set_client(   $client )
       ->set_uri(      $uri )
       ->set_url_type( $type );
}
## Fetch methods..
## ===============

## Fetch all/one
## -------------

sub fetch_urls {
#@params (self)
#@return (Pagesmith::Object::OA2::Url)*
## Return all objects from database!
  my $self = shift;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from url o
     order by url_id";
  my $urls = [ map { $self->make_url( $_ ) }
               @{$self->all_hash( $sql )||[]} ];
  return $urls;
}

sub fetch_all_urls_by_client {
#@params (self)
#@return (Pagesmith::Object::OA2::Url)*
## Return all objects from database!
  my( $self, $client ) = @_;
  $client = $client->uid if ref $client;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from url o
     where client_id = ?
     order by url_id";
  my $urls = [ map { $self->make_url( $_ ) }
               @{$self->all_hash( $sql, $client )||[]} ];
  return $urls;
}

sub fetch_all_urls_by_client_and_type {
#@params (self)
#@return (Pagesmith::Object::OA2::Url)*
## Return all objects from database!
  my( $self, $client, $type ) = @_;
  $client = $client->uid if ref $client;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from url o
     where client_id = ? and url_type = ?
     order by url_id";
  my $urls = [ map { $self->make_url( $_ ) }
               @{$self->all_hash( $sql, $client, $type )||[]} ];
  return $urls;
}

sub fetch_url {
#@params (self)
#@return (Pagesmith::Object::OA2::Url)?
## Return objects from database with given uid!
  my( $self, $uid ) = @_;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from url o
    where o.url_id = ?";
  my $url_hashref = $self->row_hash( $sql, $uid );
  return unless $url_hashref;
  my $url = $self->make_url( $url_hashref );
  return $url;
}

## Fetch by relationships
## ----------------------

## use critic

1;

__END__

package Pagesmith::Adaptor::OA2::Project;

## Adaptor for objects of type Project in namespace OA2

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
          'o.project_id, o.name, o.description, o.homepage, o.logo,
           o.privacy, o.terms, o.user_id';

const my $AUDIT_COLNAMES => q(, o.created_at, o.updated_at, o.created_by, o.updated_by, o.ip, o.useragent);

const my $TABLE_COLNAMES => {
};

const my $TABLE_TABLES => {
};

use base qw(Pagesmith::Adaptor::OA2);

use Pagesmith::Object::OA2::Project;

## Store/update functionality perl
## ===============================

sub store {
#@params (self) (Pagesmith::Object::OA2::Project object)
#@return (boolean)
## Store object in database
  my( $self, $my_object ) = @_;
  ## Check that the user has permission to write back to the db ##
  return $self->_update( $my_object ) if $my_object->uid;
  return $self->_store(  $my_object ); ## Now we perform the access options ##
}

sub _store {
#@params (self) (Pagesmith::Object::OA2::Project object)
#@return (boolean)
## Create a new entry in database
  my ($self, $my_object ) = @_;
  my $id = $self->insert( 'insert into project (
                          name,     description, homepage, logo,
                          privacy,  terms,       user_id,  created_at,
                          created_by)
                           values (?,?,?,?,?,?,?,?,?)', 'project', 'project_id',
     $my_object->get_name,    $my_object->get_description, $my_object->get_homepage,
     $my_object->get_logo,    $my_object->get_privacy,     $my_object->get_terms,
     $my_object->get_user_id, $self->now,                  $self->user );
  $my_object->set_project_id( $id );
  $my_object->store_image;
  return $id;

}

sub _update {
#@params (self) (Pagesmith::Object::OA2::Project object)
#@return (boolean)
## Create a new entry in database
  my ($self, $my_object ) = @_;
  my $flag = $self->query( 'update project set
                               name = ?,     description = ?, homepage = ?, logo = ?,
                               privacy = ?,  terms = ?,       user_id = ?,  updated_at = ?,
                               updated_by = ?
                         where project_id = ?',
     $my_object->get_name,    $my_object->get_description, $my_object->get_homepage,
     $my_object->get_logo,    $my_object->get_privacy,     $my_object->get_terms,
     $my_object->get_user_id, $self->now,                  $self->user,
     $my_object->get_project_id );
  $my_object->store_image;
  return $flag;
}

sub get_image {
  my( $self, $my_object ) = @_;
  return $self->row_hash( 'select logo_width, logo_height, logo_blob
                             from project where project_id = ?', $my_object->uid );
}

sub store_image {
  my ($self, $my_object, $width, $height, $compressed_image ) = @_;
  return $self->query( 'update project set logo_width = ?, logo_height = ?, logo_blob = ? where project_id = ?',
    $width, $height, $compressed_image, $my_object->uid );
}

## Support methods to bless SQL hash & create empty objects...
## -----------------------------------------------------------

sub make_project {
#@params (self), (string{} properties), (int partial)?
#@return (Pagesmith::Object::OA2::Project)
## Take a hashref (usually retrieved from the results of an SQL query) and create a new
## object from it.
  my( $self, $hashref, $partial ) = @_;
  return Pagesmith::Object::OA2::Project->new( $self, $hashref, $partial );
}

sub create {
#@params (self)
#@return (Pagesmith::Object::OA2::Project)
## Create an empty object
  ## Check that the user has permission to write back to the db ##
  my $self = shift;
  return $self->make_project({});
}

## Fetch methods..
## ===============

## Fetch all/one
## -------------

sub fetch_projects {
#@params (self)
#@return (Pagesmith::Object::OA2::Project)*
## Return all objects from database!
  my $self = shift;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from project o
     order by project_id";
  my $projects = [ map { $self->make_project( $_ ) }
               @{$self->all_hash( $sql )||[]} ];
  return $projects;
}

sub fetch_all_projects_by_user {
#@params (self)
#@return (Pagesmith::Object::OA2::Project)*
## Return all objects from database!
  my ( $self, $user ) = @_;
  $user = $user->uid if ref $user;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from project o
     where o.user_id = ?
     order by project_id";
  my $projects = [ map { $self->make_project( $_ ) }
               @{$self->all_hash( $sql, $user )||[]} ];
  return $projects;
}

sub fetch_project {
#@params (self)
#@return (Pagesmith::Object::OA2::Project)?
## Return objects from database with given uid!
  my( $self, $uid ) = @_;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from project o
    where o.project_id = ?";
  my $project_hashref = $self->row_hash( $sql, $uid );
  return unless $project_hashref;
  my $project = $self->make_project( $project_hashref );
  return $project;
}

sub fetch_project_by_client {
#@params (self)
#@return (Pagesmith::Object::OA2::Project)?
## Return objects from database with given uid!
  my( $self, $client ) = @_;
  $client = $client->uid if ref $client;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from project o, client c
    where o.project_id = c.project_id and c.client_id = ?";
  my $project_hashref = $self->row_hash( $sql, $client );
  return unless $project_hashref;
  my $project = $self->make_project( $project_hashref );
  return $project;
}

## Fetch by relationships
## ----------------------

## use critic

1;

__END__

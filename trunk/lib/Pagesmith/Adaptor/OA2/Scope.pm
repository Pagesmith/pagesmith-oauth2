package Pagesmith::Adaptor::OA2::Scope;

## Adaptor for objects of type Scope in namespace OA2

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
          'o.scope_id, o.code, o.name, o.description';

const my $AUDIT_COLNAMES => q();

const my $TABLE_COLNAMES => {
};

const my $TABLE_TABLES => {
};

use base qw(Pagesmith::Adaptor::OA2);
use Pagesmith::Object::OA2::Scope;
## Store/update functionality perl
## ===============================

sub store {
#@params (self) (Pagesmith::Object::OA2::Scope object)
#@return (boolean)
## Store object in database
  my( $self, $my_object ) = @_;
  ## Check that the user has permission to write back to the db ##
  return $self->_update( $my_object ) if $my_object->uid;
  return $self->_store(  $my_object ); ## Now we perform the access options ##
}

sub _store {
#@params (self) (Pagesmith::Object::OA2::Scope object)
#@return (boolean)
## Create a new entry in database
}

sub _update {
#@params (self) (Pagesmith::Object::OA2::Scope object)
#@return (boolean)
## Create a new entry in database
}


## Support methods to bless SQL hash & create empty objects...
## -----------------------------------------------------------

sub make_scope {
#@params (self), (string{} properties), (int partial)?
#@return (Pagesmith::Object::OA2::Scope)
## Take a hashref (usually retrieved from the results of an SQL query) and create a new
## object from it.
  my( $self, $hashref, $partial ) = @_;
  return Pagesmith::Object::OA2::Scope->new( $self, $hashref, $partial );
}

sub create {
#@params (self)
#@return (Pagesmith::Object::OA2::Scope)
## Create an empty object
  ## Check that the user has permission to write back to the db ##
  my $self = shift;
  return $self->make_scope({});
}

## Fetch methods..
## ===============

## Fetch all/one
## -------------

sub fetch_scopes {
#@params (self)
#@return (Pagesmith::Object::OA2::Scope)*
## Return all objects from database!
  my $self = shift;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from scope o
     order by scope_id";
  my $scopes = [ map { $self->make_scope( $_ ) }
               @{$self->all_hash( $sql )||[]} ];
  return $scopes;
}

sub fetch_scope {
#@params (self)
#@return (Pagesmith::Object::OA2::Scope)?
## Return objects from database with given uid!
  my( $self, $uid ) = @_;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from scope o
    where o.scope_id = ?";
  my $scope_hashref = $self->row_hash( $sql, $uid );
  return unless $scope_hashref;
  my $scope = $self->make_scope( $scope_hashref );
  $self->dumper( $scope );
  return $scope;
}

## Fetch by relationships
## ----------------------

## use critic

1;

__END__

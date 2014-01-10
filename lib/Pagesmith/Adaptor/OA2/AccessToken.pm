package Pagesmith::Adaptor::OA2::AccessToken;

## Adaptor for objects of type AccessToken in namespace OA2

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
          'o.accesstoken_id, o.uuid, o.expires_at, o.refresh_token_id,
           o.client_id, o.user_id, o.scope_id';

const my $AUDIT_COLNAMES => q();

const my $TABLE_COLNAMES => {
};

const my $TABLE_TABLES => {
};

use base qw(Pagesmith::Adaptor::OA2);
use Pagesmith::Object::OA2::AccessToken;
## Store/update functionality perl
## ===============================

sub store {
#@params (self) (Pagesmith::Object::OA2::AccessToken object)
#@return (boolean)
## Store object in database
  my( $self, $my_object ) = @_;
  ## Check that the user has permission to write back to the db ##
  return $self->_update( $my_object ) if $my_object->uid;
  return $self->_store(  $my_object ); ## Now we perform the access options ##
}

sub _store {
#@params (self) (Pagesmith::Object::OA2::AccessToken object)
#@return (boolean)
## Create a new entry in database
}

sub _update {
#@params (self) (Pagesmith::Object::OA2::AccessToken object)
#@return (boolean)
## Create a new entry in database
}


## Support methods to bless SQL hash & create empty objects...
## -----------------------------------------------------------

sub make_access_token {
#@params (self), (string{} properties), (int partial)?
#@return (Pagesmith::Object::OA2::AccessToken)
## Take a hashref (usually retrieved from the results of an SQL query) and create a new
## object from it.
  my( $self, $hashref, $partial ) = @_;
  return Pagesmith::Object::OA2::AccessToken->new( $self, $hashref, $partial );
}

sub create {
#@params (self)
#@return (Pagesmith::Object::OA2::AccessToken)
## Create an empty object
  ## Check that the user has permission to write back to the db ##
  my $self = shift;
  return $self->make_access_token({});
}

## Fetch methods..
## ===============

## Fetch all/one
## -------------

sub fetch_access_tokens {
#@params (self)
#@return (Pagesmith::Object::OA2::AccessToken)*
## Return all objects from database!
  my $self = shift;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from access_token o
     order by accesstoken_id";
  my $access_tokens = [ map { $self->make_access_token( $_ ) }
               @{$self->all_hash( $sql )||[]} ];
  return $access_tokens;
}

sub fetch_access_token {
#@params (self)
#@return (Pagesmith::Object::OA2::AccessToken)?
## Return objects from database with given uid!
  my( $self, $uid ) = @_;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from access_token o
    where o.accesstoken_id = ?";
  my $access_token_hashref = $self->row_hash( $sql, $uid );
  return unless $access_token_hashref;
  my $access_token = $self->make_access_token( $access_token_hashref );
  $self->dumper( $access_token );
  return $access_token;
}

## Fetch by relationships
## ----------------------

## use critic

1;

__END__

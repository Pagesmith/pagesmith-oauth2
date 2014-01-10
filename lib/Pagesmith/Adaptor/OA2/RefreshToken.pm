package Pagesmith::Adaptor::OA2::RefreshToken;

## Adaptor for objects of type RefreshToken in namespace OA2

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
          'o.refreshtoken_id, o.uuid, o.expires_at, o.access_token_id,
           o.client_id, o.user_id';

const my $AUDIT_COLNAMES => q();

const my $TABLE_COLNAMES => {
};

const my $TABLE_TABLES => {
};

use base qw(Pagesmith::Adaptor::OA2);
use Pagesmith::Object::OA2::RefreshToken;
## Store/update functionality perl
## ===============================

sub store {
#@params (self) (Pagesmith::Object::OA2::RefreshToken object)
#@return (boolean)
## Store object in database
  my( $self, $my_object ) = @_;
  ## Check that the user has permission to write back to the db ##
  return $self->_update( $my_object ) if $my_object->uid;
  return $self->_store(  $my_object ); ## Now we perform the access options ##
}

sub _store {
#@params (self) (Pagesmith::Object::OA2::RefreshToken object)
#@return (boolean)
## Create a new entry in database
}

sub _update {
#@params (self) (Pagesmith::Object::OA2::RefreshToken object)
#@return (boolean)
## Create a new entry in database
}


## Support methods to bless SQL hash & create empty objects...
## -----------------------------------------------------------

sub make_refresh_token {
#@params (self), (string{} properties), (int partial)?
#@return (Pagesmith::Object::OA2::RefreshToken)
## Take a hashref (usually retrieved from the results of an SQL query) and create a new
## object from it.
  my( $self, $hashref, $partial ) = @_;
  return Pagesmith::Object::OA2::RefreshToken->new( $self, $hashref, $partial );
}

sub create {
#@params (self)
#@return (Pagesmith::Object::OA2::RefreshToken)
## Create an empty object
  ## Check that the user has permission to write back to the db ##
  my $self = shift;
  return $self->make_refresh_token({});
}

## Fetch methods..
## ===============

## Fetch all/one
## -------------

sub fetch_refresh_tokens {
#@params (self)
#@return (Pagesmith::Object::OA2::RefreshToken)*
## Return all objects from database!
  my $self = shift;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from refresh_token o
     order by refreshtoken_id";
  my $refresh_tokens = [ map { $self->make_refresh_token( $_ ) }
               @{$self->all_hash( $sql )||[]} ];
  return $refresh_tokens;
}

sub fetch_refresh_token {
#@params (self)
#@return (Pagesmith::Object::OA2::RefreshToken)?
## Return objects from database with given uid!
  my( $self, $uid ) = @_;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from refresh_token o
    where o.refreshtoken_id = ?";
  my $refresh_token_hashref = $self->row_hash( $sql, $uid );
  return unless $refresh_token_hashref;
  my $refresh_token = $self->make_refresh_token( $refresh_token_hashref );
  $self->dumper( $refresh_token );
  return $refresh_token;
}

## Fetch by relationships
## ----------------------

## use critic

1;

__END__

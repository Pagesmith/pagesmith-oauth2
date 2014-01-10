package Pagesmith::Adaptor::OA2::Permission;

## Adaptor for relationship Permission in namespace OA2

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

use base qw(Pagesmith::Adaptor::OA2);

use Const::Fast qw(const);
## no critic (ImplicitNewlines)

const my $DATA_COLUMNS => q();

## ----------------------------------------------------------------------
## Store and update methods
## ----------------------------------------------------------------------

sub store {
#@params (self) ()
#@return (boolean)
## Store value of relationship in database
  my( $self, $pars ) = @_;

  my $sql = '
    insert ignore into permission
         ( user_id,
           client_id,
           scope_id )
  values ( ?,?,? )';

  $self->query( $sql,exists $params->{'user_id'} ? $params->{'user_id'} : $params->{'user'}->user_id,
           exists $params->{'client_id'} ? $params->{'client_id'} : $params->{'client'}->client_id,
           exists $params->{'scope_id'} ? $params->{'scope_id'} : $params->{'scope'}->scope_id,
  );
  return $self->update( $pars );
}

sub update {
#@params (self) (hash)
#@return (boolean)
## Store value of relationship in database
  my( $self, $pars ) = @_;

  my $sql = '
    update permission
       set
     where user_id = ?,
           client_id = ?,
           scope_id = ?';

  return $self->query( $sql,exists $params->{'user_id'} ? $params->{'user_id'} : $params->{'user'}->user_id,
           exists $params->{'client_id'} ? $params->{'client_id'} : $params->{'client'}->client_id,
           exists $params->{'scope_id'} ? $params->{'scope_id'} : $params->{'scope'}->scope_id,
  );
}

## ----------------------------------------------------------------------
## Fetch methods
## ----------------------------------------------------------------------

sub get_permission {
#@param (self)
#@param (Pagesmith::Adaptor::OA2::User|integer) user
#@param (Pagesmith::Adaptor::OA2::Client|integer) client
#@param (Pagesmith::Adaptor::OA2::Scope|integer) scope
#@returns (hash)?
## Fetch single row from database
  my( $self, $user, $client, $scope )  = @_;
  my $sql = '
    select ? as user_id,
           ? as client_id, ? as client_code,
           ? as scope_id'.$DATA_COLUMNS.'
      from permission as rel
     where rel.user_id=?,
           rel.client_id=?,
           rel.scope_id=?';
  return $self->hash( $sql,
    ref $user ? $user->id : $user,
    ref $client ? $client->id : $client,
    ref $client ? $client->code : q(-),
    ref $scope ? $scope->id : $scope,
    $user->id,
    $client->id,
    $scope->id );
}

sub get_all_permission {
#@param (self)
#@returns (hash[])
## Fetch arrayref of rows from database
  my( $self )  = @_;
  my $sql = '
    select rel.user_id,
           rel.client_id,
           client.code as client_code,
           rel.scope_id'.$DATA_COLUMNS.'
      from permission as rel, user, client, scope
     where rel.user_id=user.user_id,
           rel.client_id=client.client_id,
           rel.scope_id=scope.scope_id';
  return $self->all_hash( $sql )||[];
}

## use critic

1;

__END__

Purpose
-------

Relationship adaptors like this represent relationships between core objects
(without themselves being objects). Many pairs of objects may have multiple
relationships between them.


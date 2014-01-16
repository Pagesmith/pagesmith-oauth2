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
          'o.accesstoken_id, o.uuid, unix_timestamp(o.expires_at) as expires_at_ts,
           o.expires_at, o.refreshtoken_id, o.client_id, o.user_id';

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
  my( $self, $my_object ) = @_;
  my $at_id = $self->insert( 'insert into accesstoken (uuid, expires_at, user_id, client_id, refreshtoken_id)
                              values (?,?,?,?,?)', 'authcode', 'authcode_id',
    $my_object->get_uuid,
    $my_object->get_expires_at,
    $my_object->get_user_id,
    $my_object->get_client_id,
    $my_object->get_refreshtoken_id||0,
  );
  $my_object->set_accesstoken_id( $at_id );
  return $at_id;
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
  my ($ts,$ts_unix) = $self->offset(1,'hour');
  return $self->make_access_token({'uuid'=>$self->safe_uuid,'scopes'=>{},'expires_at'=>$ts,'expires_at_ts'=>$ts_unix,'refreshtoken_id'=>0});
}

sub create_from_authcode {
  my( $self, $authcode ) = @_;
  my ($ts,$ts_unix) = $self->offset(2,'day');
  my $uuid = $self->safe_uuid;
  my $token = $self->make_access_token( {
    'uuid'            => $uuid,
    'scopes'          => $authcode->scopes_ref,
    'expires_at'      => $ts,
    'expires_at_ts'   => $ts_unix,
    'refreshtoken_id' => 0,
  });
  my $at_id = $self->insert(
    'insert ignore into accesstoken
           (uuid,expires_at,refreshtoken_id,client_id,user_id)
     select ?, ?, 0, client_id, user_id
       from authcode
      where authcode_id = ?', 'accesstoken', 'accesstoken_id', $uuid,$ts,$authcode->uid );
  $self->query( 'insert ignore into accesstoken_scope select ?,scope_id from authcode_scope where authcode_id = ?',
    $at_id, $authcode->uid );
  $token->set_accesstoken_id( $at_id );
  return $token;
}

sub create_from_refreshtoken {
  my( $self, $refresh_token ) = @_;
  my ($ts,$ts_unix) = $self->offset(2,'day');
  my $uuid = $self->safe_uuid;
  my $token = $self->make_access_token( {
    'uuid'            => $uuid,
    'scopes'          => $refresh_token->scopes_ref,
    'expires_at'      => $ts,
    'expires_at_ts'   => $ts_unix,
    'refreshtoken_id' => $refresh_token->uid,
  });
  my $at_id = $self->insert(
    'insert ignore into accesstoken (uuid,expires_at,refreshtoken_id,client_id,user_id)
     select ?,?,refreshtoken_id,client_id,user_id
       from refreshtoken
      where refreshtoken_id = ?', 'accesstoken', 'accesstoken_id', $uuid,$ts,$refresh_token->uid );
  $self->query( 'insert ignore into accesstoken_scope select ?,scope_id from refreshtoken_scope where refreshtoken_id = ?',
    $at_id, $refresh_token->uid );
  $token->set_accesstoken_id( $at_id );
  return $token;
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
      from accesstoken o
     where o.expires_at > now()
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
      from accesstoken o
    where o.accesstoken_id = ? and o.expires_at > now()";
  my $access_token_hashref = $self->row_hash( $sql, $uid );
  return unless $access_token_hashref;
  my $access_token = $self->make_access_token( $access_token_hashref );
  return $access_token;
}

sub fetch_access_token_by_code {
#@params (self)
#@return (Pagesmith::Object::OA2::AccessToken)?
## Return objects from database with given uid!
  my( $self, $uuid ) = @_;
  my $sql = "
    select $FULL_COLNAMES$AUDIT_COLNAMES
      from accesstoken o
    where o.uuid = ? and o.expires_at > now()";
  my $access_token_hashref = $self->row_hash( $sql, $uuid );
  return unless $access_token_hashref;
  my $access_token = $self->make_access_token( $access_token_hashref );
  return $access_token;
}

## Fetch by relationships
## ----------------------

## use critic

sub clear_scopes {
  my ( $self, $access_token ) = @_;
  $access_token = ref $access_token ? $access_token->uid : $access_token;
  return $self->query( 'delete from accesstoken_scope where accesstoken_id = ?', $access_token );
}

sub add_scope {
  my ( $self, $access_token, $scope ) = @_;
  $access_token = ref $access_token ? $access_token->uid : $access_token;
  $scope     = ref $scope     ? $scope->uid     : $scope;
  return $self->query( 'insert ignore into accesstoken_scope (accesstoken_id,scope_id) values(?,?)', $access_token, $scope );
}

### Optimised queries...

sub validate_token {
  my ( $self, $uuid ) = @_;
  return $self->row_hash( '
   select c.code as audience, u.uuid as userid,
          timestampdiff(second,now(),a.expires_at) as expires_in,
          group_concat( s.code order by s.code ) as scope
     from accesstoken as a, user u, client c, accesstoken_scope acs, scope s
    where a.uuid = ? and a.expires_at > now() and  a.user_id = u.user_id and
          a.client_id = c.client_id and
          s.scope_id = acs.scope_id and acs.accesstoken_id = a.accesstoken_id
 group by c.code, u.uuid, expires_in', $uuid );
}
1;

__END__

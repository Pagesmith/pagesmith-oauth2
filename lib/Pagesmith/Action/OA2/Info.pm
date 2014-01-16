package Pagesmith::Action::OA2::Info;

## Handles external links (e.g. publmed links)
## Author         : js5
## Maintainer     : js5
## Created        : 2009-08-12
## Last commit by : $Author$
## Last modified  : $Date$
## Revision       : $Revision$
## Repository URL : $HeadURL$

use strict;
use warnings;
use utf8;

use version qw(qv); our $VERSION = qv('0.1.0');

use base qw(Pagesmith::Action::OA2);

sub run {
  my $self = shift;

  my $adap = $self->adaptor( 'AccessToken' );
  return $self->forbidden unless $adap;

  my $accesstoken = $adap->fetch_access_token_by_code( $self->param('access_token') );

  return $self->forbidden unless $accesstoken->has_scope( 'profile' );

  my $oa_user = $accesstoken->get_user;
  return $self->not_found unless $oa_user;

  my $email = $oa_user->get_username;
  my $uuid  = $oa_user->get_uuid;

  return $self->json_print({
    'email'  => $email,
    'id'     => $email||$uuid,
    'ext_id' => $uuid,
    'name'   => $oa_user->get_name,
  });
}



1;

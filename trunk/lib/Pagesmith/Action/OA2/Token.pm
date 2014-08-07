package Pagesmith::Action::OA2::Token;

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

use Apache2::Const qw(HTTP_METHOD_NOT_ALLOWED);
use Const::Fast qw(const);

use base qw(Pagesmith::Action::OA2);

sub run {
  my $self = shift;
  # return HTTP_METHOD_NOT_ALLOWED unless $self->is_post;
  $self->dump_params;
  my $client_id     = $self->param( 'client_id' );
  my $client_secret = $self->param( 'client_secret' );
  my $code          = $self->param( 'code' );
  my $grant_type    = $self->param( 'grant_type' );
  my $redirect_uri  = $self->param( 'redirect_uri'   )||q();

  my $aca           = $self->adaptor( 'AuthCode' );
  my $auth_code     = $aca->fetch_authcode_by_uuid( $code );
  return $self->not_found unless $auth_code;

  my $client        = $aca->get_other_adaptor( 'Client' )->fetch_client_by_code( $client_id );
  return $self->not_found unless $client;
  return $self->not_found unless $client->get_secret eq $client_secret;
  return $self->not_found unless $client->uid eq $auth_code->get_client_id;

  my $url = $auth_code->get_url;
  return $self->not_found unless $redirect_uri eq $url->get_uri;
  my $return_data = { 'token_type' => 'Bearer' };

  my $oa_user = $auth_code->get_user;
  my $access_token;
  if( $auth_code->get_access_type eq 'offline' ) {
    my $refresh_token = $auth_code->create_refreshtoken;
       $access_token  = $refresh_token->create_accesstoken;
    $return_data->{'refresh_token'} = $refresh_token->get_uuid;
  } else {
    $access_token = $auth_code->create_accesstoken;
  }
  $return_data->{'access_token'} = $access_token->get_uuid;
  $return_data->{'expires_in'}   = $access_token->expires_in;
  return $self->json_print( $return_data );
}

1;

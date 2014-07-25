package Pagesmith::Action::OA2::Info;

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

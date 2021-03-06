package Pagesmith::Action::OA2::Revoke;

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

use Const::Fast qw(const);

const my $METHODS => {
  'Project'      => 'fetch_project_by_code',
  'AccessToken'  => 'fetch_accesstoken_by_uuid',
  'RefreshToken' => 'fetch_refreshtoken_by_uuid',
};

sub run {
  my $self = shift;
  my $type = $self->next_path_info;
  return $self->no_content unless exists $METHODS->{$type};

  my $method = $METHODS->{$type};
  my $my_obj = $self->adaptor( $type )->$method( $self->next_path_info );
  return $self->no_content unless exists $METHODS->{$type};
  $my_obj->revoke( $self->me );
  if( $type eq 'Project' ) {
    $self->flash_message( {
      'title' => 'Tokens revoked',
      'body'  => sprintf 'All tokens have been revoked for application "%s"', $self->encode( $my_obj->get_name ),
    } );
  } else {
    $self->flash_message( {
      'title' => 'Tokens revoked',
      'body'  => 'The selected tokens have been revoked',
    } );
  }
  return $self->redirect( '/oa2/Dashboard' );
}

1;

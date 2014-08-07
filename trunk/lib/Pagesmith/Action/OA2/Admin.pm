package Pagesmith::Action::OA2::Admin;

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

## Admininstration wrapper for objects in namespace OA2

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

use base qw(Pagesmith::Action::OA2);

sub run {
#@params (self)
## Display tabs containing ajax containers for each of the components...
  my $self = shift;
  return $self->login_required unless $self->user->logged_in;

  ## no critic (LongChainsOfMethodCalls)
  my $tabs = $self->tabs
    ->add_tab( 't_0', 'Information', '<p>Put stuff here</p>' )
    ->add_tab( 't_access_token', 'Access token', '<% OA2_Admin_AccessToken -ajax %>' )
    ->add_tab( 't_auth_code', 'Auth code', '<% OA2_Admin_AuthCode -ajax %>' )
    ->add_tab( 't_client', 'Client', '<% OA2_Admin_Client -ajax %>' )
    ->add_tab( 't_project', 'Project', '<% OA2_Admin_Project -ajax %>' )
    ->add_tab( 't_refresh_token', 'Refresh token', '<% OA2_Admin_RefreshToken -ajax %>' )
    ->add_tab( 't_scope', 'Scope', '<% OA2_Admin_Scope -ajax %>' )
    ->add_tab( 't_url', 'Url', '<% OA2_Admin_Url -ajax %>' )
    ->add_tab( 't_user', 'User', '<% OA2_Admin_User -ajax %>' );
  ## use critic;
  return $self->my_wrap( 'Admin for OA2', $tabs->render );
}

1;

__END__

package Pagesmith::Action::OA2::AdminLogo;

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

## Admininstration action for objects of type Project
## in namespace OA2

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
## Display admin for table for Project in OA2
  my $self        = shift;
  return $self->no_content unless $self->user->logged_in;
  my $user_adap = $self->adaptor('User');
  my $user = $user_adap->fetch_user_by_auth_method_username( $self->user->auth_method, $self->user->uid );
  return $self->no_content unless $user;

  my $project_id  = $self->next_path_info;
  my $project     = $user_adap->get_other_adaptor( 'Project' )->fetch_project( $project_id );
  return $self->no_content unless $project->get_user_id == $user->uid || $user->is_admin;

  my $img_details = $project->get_image;
  return $self->no_content unless $img_details;

  return $self->content_type( 'image/png' )->print( $img_details->{'logo_blob'} )->ok;
}

1;

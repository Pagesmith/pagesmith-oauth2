package Pagesmith::MyForm::OA2::Login;

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

## Allow client to use given permissions...
##
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

use Const::Fast qw(const);


use base qw(Pagesmith::MyForm::Login Pagesmith::Support::OA2);

sub initialize_form {
  my $self = shift;
  $self->SUPER::initialize_form;
  my $st = $self->add_stage( 'Login' );

  my $client_id  = $self->attribute( 'client_id' ) ||q();
  if( $client_id ) {
    $self->{'oa_client'}      = $self->adaptor( 'Client' )->fetch_client( $client_id );
  }
  if( $self->{'oa_client'} ) {
    $self->{'oa_project'}     = $self->{'oa_client'}->get_project;
    if( $self->{'oa_project'} ) {
      $st->unshift_section( 'OAuth2 login for '.$self->{'oa_project'}->get_name );
      my $img = $self->{'oa_project'}->get_image;
      $self->add( 'Information', 'desc' )->set_caption(
        sprintf '<img class="left" src="/oa2/Logo/%s" height="%d" width="%d" alt="*" style="margin-right: 1em" />%s<div class="clear">&nbsp;</div>',
          $self->{'oa_client'}->get_code, $img->{'logo_height'},
          $img->{'logo_width'}, $self->encode( $self->{'oa_project'}->get_description ) );
      $self->add( 'Information', 'This application is requesting to authenticate you with your account details' );
    }
  } else {
    $self->add( 'Heading', 'OAuth2 error' );
  }
  return $self;
}

sub on_cancel {
  my $self = shift;
  my $href = $self->attribute( 'ref' );
  return $href ? "$href&error=access_denied" : $self->base_url( $self->r );
}

1;

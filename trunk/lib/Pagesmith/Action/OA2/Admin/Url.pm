package Pagesmith::Action::OA2::Admin::Url;

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

## Admin table display for objects of type Url in
## namespace OA2

## Author         : James Smith <js5@sanger.ac.uk>
## Maintainer     : James Smith <js5@sanger.ac.uk>
## Created        : 30th Jul 2014

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
## Display admin for table for Url in OA2
  my $self = shift;

  return $self->login_required unless $self->user->logged_in;
  return $self->no_permission  unless $self->me && $self->me->is_superadmin;

  ## no critic (LongChainsOfMethodCalls)
  return $self->my_wrap( q(OA2's Url),
    $self
      ->my_table
      ->add_columns(
        { 'key' => 'get_url_id',       'label' => 'Url id', 'format' => 'd' },
        { 'key' => 'get_url_type',     'label' => 'Url type' },
        { 'key' => 'get_uri',          'label' => 'Uri' },
        { 'key' => 'get_project_name', 'label' => 'Project' },
        { 'key' => '_edit', 'label' => 'Edit?', 'template' => 'Edit', 'align' => 'c', 'no_filter' => 1,
          'link' => '/form/OA2_Admin_Url/[[h:uid]]' },
      )
      ->add_data( @{$self->adaptor( 'Url' )->fetch_all_urls||[]} )
      ->render.
    $self->button_links( '/form/OA2_Admin_Url', 'Add' ),
  );
  ## use critic
}

1;

__END__
Notes
-----


package Pagesmith::Action::OA2::Dashboard;

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
use Const::Fast qw(const);
const my $THIS_URL => '/oa2/Dashboard';
use base qw(Pagesmith::Action::OA2);

sub run {
#@params (self)
## Display admin for table for Project in OA2
  my $self = shift;
  return $self->login_required unless $self->user->logged_in;

  my $user = $self->me;
  return $self->my_wrap( 'OAuth2', '<p>You have not approved any applications to use your credentials</p>' ) unless $user;

  my $padap    = $self->adaptor('Project');
  my $projects = $user->fetch_projects;
  my $access   = $user->fetch_accesstokens;
  my $refresh  = $user->fetch_refreshtokens;

  my $project_cache;
  ## no critic (LongChainsOfMethodCalls)
  return $self->html->wrap('My projects and tokens',
    $self->tabs
         ->add_tab( 't_my', 'My projects',
           $self->my_table
                ->add_columns(
                  { 'key' => 'get_code',        'label' => 'Code', },
                  { 'key' => 'get_name',        'label' => 'Name', },
                  { 'key' => 'get_description', 'label' => 'Description', },
                  { 'key' => 'logo',            'label' => 'Logo', 'template' => '<img src="/oa2/Logo/[[u:get_code]]" height="[[u:get_logo_height]]" width="[[u:get_logo_width]]" alt="[logo]">' },
                )
                ->add_data( @{$projects} )
                ->render,
         )
         ->add_tab( 't_project', 'Permitted projects', q(),
         )
         ->add_tab( 't_access', 'Access Tokens',
           $self->my_table
                ->add_columns(
                  { 'key' => 'get_uuid',       'label' => 'Code',   },
                  { 'key' => 'get_expires_at', 'label' => 'Expiry',  'format' => 'date' },
                  { 'key' => 'get_name',       'label' => 'Project',
                    'code_ref' => sub {
                      my $id = $_[0]->get_project_id;
                      $project_cache->{$id} ||= $padap->fetch_project( $id );
                      return $project_cache->{$id}->get_name;
                    }   },
                )
                ->add_data( @{$access} )
                ->render,
         )
         ->add_tab( 't_refresh', 'Refresh tokens',
           $self->my_table
                ->add_columns(
                  { 'key' => 'get_uuid',       'label' => 'Code',   },
                  { 'key' => 'get_expires_at', 'label' => 'Expiry', 'format' => 'date' },
                  { 'key' => 'get_name',       'label' => 'Project',
                    'code_ref' => sub {
                      my $id = $_[0]->get_project_id;
                      $project_cache->{$id} ||= $padap->fetch_project( $id );
                      return $project_cache->{$id}->get_name;
                    }   },
                )
                ->add_data( @{$refresh} )
                ->render,
         )
         ->render,
  )->ok;
  ## use critic
}

1;

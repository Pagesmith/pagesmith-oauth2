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
  my $projects = $user->fetch_permitted_projects;
  my $access   = $user->fetch_accesstokens;
  my $refresh  = $user->fetch_refreshtokens;
  unless ( @{$projects} ) {
    return $self->html->wrap('My applications and tokens', '<p>You currently have no applications permitted</p>' )->ok;
  }
  my $project_cache;
  ## no critic (LongChainsOfMethodCalls)
  my $scopes    = $self->adaptor( 'Scope' )->fetch_all_scopes;
  my $scope_map = {};
  $scope_map->{ $_->uid } = $_ foreach @{$scopes};

  my $tabs = $self->tabs->add_tab( 't_my', 'Permitted applications',
    $self->my_table
         ->add_columns(
           { 'key' => 'get_name',        'label' => 'Application', 'template' => '<div class="left" style="padding-right: 1em"><img src="/oa2/Logo/[[u:get_code]]" height="[[u:get_logo_height]]" width="[[u:get_logo_width]]" alt="[logo]"></div><strong>[[h:get_name]]</strong><br />[[h:get_description]]' },
           { 'key' => 'permissions',     'label' => 'Permissions', 'align' => 'c',
             'code_ref' => sub {
               my $allowed_scopes = $_[0]->get_attribute( 'scopes' );
               my @scopes = map { $allowed_scopes->{$_} eq 'yes' ? $scope_map->{$_}->get_name : () } keys %{$allowed_scopes};
               return join q(, ), sort @scopes;
             },
           },
           { 'key' => '_remove', 'label' => 'Remove', 'link' => '/oa2/Remove/[[h:get_code]]', 'template' => 'Remove application', 'align' => 'c' },
           { 'key' => '_revoke', 'label' => 'Revoke', 'link' => '/oa2/Revoke/Project/[[h:get_code]]', 'template' => 'Revoke all tokens', 'align' => 'c' },
         )
         ->add_data( @{$projects} )
         ->render,
  );

  $tabs->add_tab( 't_access', 'Access Tokens',
    $self->my_table
         ->add_columns(
           { 'key' => 'get_name',       'label' => 'Application',
             'code_ref' => sub {
               my $id = $_[0]->get_project_id;
               $project_cache->{$id} ||= $padap->fetch_project( $id );
               return $project_cache->{$id}->get_name;
             }   },
           { 'key' => '_revoke', 'label' => 'Revoke', 'link' => '/oa2/Revoke/AccessToken/[[h:get_uuid]]', 'template' => 'Revoke token', 'align' => 'c' },
         )
         ->add_data( @{$access} )
         ->render,
  ) if @{$access};

  $tabs->add_tab( 't_refresh', 'Refresh tokens',
    $self->my_table
         ->add_columns(
           { 'key' => 'get_name',       'label' => 'Application',
             'code_ref' => sub {
               my $id = $_[0]->get_project_id;
               $project_cache->{$id} ||= $padap->fetch_project( $id );
               return $project_cache->{$id}->get_name;
             }   },
           { 'key' => '_revoke', 'label' => 'Revoke', 'link' => '/oa2/Revoke/RefreshToken/[[h:get_uuid]]', 'template' => 'Revoke token', 'align' => 'c' },
         )
         ->add_data( @{$refresh} )
         ->render,
  ) if @{$refresh};

  return $self->html->wrap('My applications and tokens', $tabs->render )->ok;
  ## use critic
}

1;

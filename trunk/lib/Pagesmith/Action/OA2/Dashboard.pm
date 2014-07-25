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

  my $user_adap = $self->adaptor('User')->attach_user( $self->user );
  my $user      = $user_adap->fetch_user_by_username( $self->user->username ) ||
                  $user_adap->create->set_username(   $self->user->username );

  return $self->run_not_developer( $user ) unless $user->is_developer;

  ## Get a list of projects....
  my @projects = @{$user->get_all_projects||[]};
  my @html = '<h2><a class="right btt" href="/form/OA2_Project">Add new project</a>My Projects</p>';

  unless( @projects ) {
    push @html, '<p>You do not currently have any projects</p>';
  } else {
    foreach my $project (@projects) {
      my $image_details = $project->get_image;
      ## no critic (LongChainsOfMethodCalls)
      my $twocol = $self->twocol
        ->add_entry( 'Logo',        $image_details->{'logo_width'}
                                  ? sprintf '<img src="/oa2/AdminLogo/%d" width="%d" height="%d" alt="*logo" />',
                                      $project->uid, $image_details->{'logo_width'}, $image_details->{'logo_height'}
                                  : '<p>No logo</p>' )
        ->add_entry( 'Description', $self->encode( $project->get_description ) )
        ->add_entry( 'Home page',   sprintf '<%% Link %s %%>', $self->encode( $project->get_homepage ) )
        ->add_entry( 'Privacy',     sprintf '<%% Link %s %%>', $self->encode( $project->get_privacy ) )
        ->add_entry( 'Terms',       sprintf '<%% Link %s %%>', $self->encode( $project->get_terms ) )
        ->add_entry( q(),           sprintf '<a class="btt" href="/form/OA2_Project/%d">Edit project</a>',
                                            $project->uid );
      ## use critic
      my $clients = $project->get_all_clients;
      my $extra = q();
      if( @{$clients} ) {
        ## no critic (LongChainsOfMethodCalls)
        $extra = $self->table
          ->add_columns(
            { 'key' => 'get_code',        'label' => 'Client ID',     'format' => 'h' },
            { 'key' => 'get_secret',      'label' => 'Client Secret', 'format' => 'h' },
            { 'key' => 'get_client_type', 'label' => 'Client type',   'format' => 'h' },
            { 'key' => 'x',               'label' => 'Edit',          'align' => 'c', 'template' => '<a class="btt" href="/form/OA2_Client/[[h:uid]]">Edit</a>' },
          )->add_data( @{$clients} )->render;
        ## use critic
      } else {
        $extra = '<p>No client ids for this project</p>'
      }
      push @html, sprintf '
<h3 class="clear"><a class="right btt" href="/form/OA2_Client/project-%d">Add new client</a>%s</h3>
<div class="col1">
  %s
</div>
<div class="col2">
  %s
  <p class="r">
</div>
',
        $project->uid,
        $self->encode( $project->get_name ),
        $twocol->render,
        $extra;
    }
  }

  return $self->wrap_no_heading( 'My Projects',
    join q(), @html,
     )->ok;
}

sub run_not_developer {
  my( $self, $user ) = @_;
## Look to see if the user has created
    ## Lets look to see if the user has agreed ts and cs...
  if( $self->next_path_info||q() eq 'agree' ) {
    $user->set_developer('yes')->store;
    return $self->redirect( $THIS_URL );
  }
  return $self->wrap( 'OA2 Developer pages', sprintf '
<p>You must first accept the terms and conditions below</p>
<div class="scrollable vert-sizing {padding:400,minheight:150}" style="border:1px solid #999; margin: 5px 20px">
  <h3>Terms and conditions</h3>
  <%% LoremIpsum 10 paras %%>
</div>
<p class="c"><a class="btt" href="%s/agree">I agree to the terms and conditions stated above</a></p>', $THIS_URL )->ok;
}

1;
__END__

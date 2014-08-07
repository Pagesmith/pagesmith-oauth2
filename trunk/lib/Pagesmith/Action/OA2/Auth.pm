package Pagesmith::Action::OA2::Auth;

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
use List::MoreUtils qw(all);

use base qw(Pagesmith::Action::OA2);

## no critic (ExcessComplexity)
sub return_error {
  my ( $self, $code, $state, $redirect_uri ) = @_;
  return $self->redirect( sprintf '%s%sstate=%s&error=%s',
    $redirect_uri,
    $redirect_uri =~ m{[?]}mxs ? q(&) : q(?),
    $state,
    $code || 'access_denied' );
}
sub run {
  my $self = shift;

## Process the input....
## Want to stick as closely as possible to facebook / google...

  my $redirect_uri    = $self->trim_param( 'redirect_uri'   )||q();
  my $state           = $self->trim_param( 'state'          )||q();
  my $error           = $self->trim_param( 'error' )         ||q();
  my $response_type   = $self->trim_param( 'response_type'  )||q();
     $response_type   = 'code' unless $response_type eq 'token';
  my $client_id       = $self->trim_param( 'client_id'      )||q();
  my $access_type     = $self->trim_param( 'access_type'    )||q();
     $access_type     = 'online' unless $access_type eq 'offline';

  my $approval_prompt = $self->trim_param( 'approval_prompt' )||q();
     $approval_prompt = 'auto' unless $approval_prompt eq 'force';
  my $login_hint      = $self->trim_param( 'login_hint'     )||q();
  my $inc_scopes      = $self->trim_param( 'include_granted_scopes' ) || q();
     $inc_scopes      = 'false' unless $inc_scopes eq 'true';
  my @request_scopes  = split m{\s+}mxs, $self->trim_param( 'scope' )||q();

  ## check we know what the client id is...
## Get information about the client!
  my $ca              = $self->adaptor( 'Client' );
  my $client          = $ca->fetch_client_by_code( $client_id );
  return $self->redirect( '/oa2-core/unknown_client.html' ) unless $client;

  ## validate redirect_uri against client_id;
  my @urls     = grep { $_->is_url_type( 'redirect' ) } @{$client->fetch_all_urls||[]};

  my %url_hash = map { $_->get_uri => $_ } @urls;

  return $self->redirect( '/oa2-core/incompatible_redirect.html' ) unless exists $url_hash{$redirect_uri};

  return $self->return_error( 'access_denied', $state, $redirect_uri ) if $error;

  my $url_obj   = $url_hash{$redirect_uri};
  ## Now get information about Scopes....
  my $scopes          = $client->get_other_adaptor( 'Scope' )->fetch_all_scopes;
  my %scope_hash      = map { $_->get_code => $_ } @{$scopes};
  my $n_scopes        = @request_scopes;
  @request_scopes     = map { exists $scope_hash{$_} ? $scope_hash{$_} : () } @request_scopes;
  ## The site has requested a scope which we don't know about!
  return $self->return_error( 'invalid_scope' ) unless $n_scopes == @request_scopes;

  ## Mimic google specific prompt stuff!

  ## Which sub-part of process are we currently going through?
  ## User is not logged in so we will display a standard login form
  unless( $self->user->logged_in ) { ## User is logged in?
    ## Create login form object.. and redirect to login page...
    ## Note that this is an extended login page which has information
    ## about the client embedded at the top...
    return $self->redirect( ## no critic (LongChainsOfMethodCalls)
      $self->form( 'OA2::Login' )
        ->add_attribute( 'client_id', $client->uid )
        ->update_attribute( 'ref', $self->r->unparsed_uri )
        ->store
        ->action_url_get );
  }

  ## Lets see if we have a user in the database!?!
  my $ua      = $ca->get_other_adaptor('User');
  my $oa_user = $self->me(1);

  $self->oauth_error( 'cannot create user object' ) unless $oa_user->uid;

  ## Now we have a user!
  my $project     = $client->get_project;
  my $pa          = $ca->get_other_adaptor('Permission');
## This bit we need to fix!!!
  my $permissions = $pa->fetch_permissions_by_user_project( $oa_user, $project )||[];
  my %perm_scopes = map { ($_->{'code'} => $scope_hash{ $_->{'code'}} )}
                    @{$permissions};
  my %perm_hash   = map { $_->{'scope_id'} => $_->{'allowed'} }
                    @{$permissions};
  my %granted_scopes = map { $_->uid => exists $perm_hash{$_->uid} && $perm_hash{$_->uid} eq 'yes' }
                       @request_scopes;

  my $request_permission = 1;
     $request_permission = 0 if all { $_ } values %granted_scopes;
     $request_permission = 1 if $approval_prompt eq 'force';

  if( $request_permission ) {
    ## We now know we need to request permission (or have just requested it!)
    ## no critic (LongChainsOfMethodCalls)
    my $form = $self->form( 'OA2::Permit' );
    return $self->redirect( $form
      ->update_attribute( 'ref', $self->r->unparsed_uri )
      ->add_attribute(    'client_id', $client->uid )
      ->add_attribute(    'scope_list', join q( ), map { sprintf '%d %s', $scope_hash{$_->get_code}->uid, exists $granted_scopes{$_->get_code} ? 1 : 0 } @request_scopes )
      ->store
      ->action_url_get );
    ## use critic
  }

  my $auth_code    = $oa_user->create_auth_code( $client, $url_obj, $access_type, $self->user->uuid, $self->user->auth_method );
  $auth_code->add_scope( $_ ) foreach @request_scopes;
  if( $inc_scopes ) {
    $auth_code->add_scope( $_ ) foreach values %perm_scopes;
  }

  ## Redirect....
  if( $response_type eq 'token' ) {
    my $access_token = $auth_code->create_accesstoken;
    return $self->redirect(
      sprintf '%s#access_token=%s&token_type=%s&expires_in=%d&state=%s',
        $redirect_uri,
        $access_token->get_uuid, 'Bearer', $access_token->expires_in, $state );
  }

  return $self->redirect( sprintf '%s?state=%s&code=%s', $redirect_uri, $state, $auth_code->get_uuid );
}
## use critic
1;

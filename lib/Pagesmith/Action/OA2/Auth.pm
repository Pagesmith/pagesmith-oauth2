package Pagesmith::Action::OA2::Auth;

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
sub run {
  my $self = shift;

## Process the input....
## Want to stick as closely as possible to facebook / google...

  my $redirect_uri    = $self->trim_param( 'redirect_uri'   )||q();
  my $state           = $self->trim_param( 'state'          )||q();
  my ($path)          = split m{[?]}mxs, $redirect_uri;
  my $error           = $self->trim_param( 'error' )         ||q();
  $self->dump_params;
  if( $error eq 'access_denied') {
    my $uri = sprintf '%s%sstate=%s&error=access_denied',
                 $redirect_uri,
                 $redirect_uri =~ m{[?]}mxs ? q(&) : q(?),
                 $state;
    return $self->redirect( $uri );
  }
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
  my $ca      = $self->adaptor( 'Client' );
  my $client  = $ca->fetch_client_by_code( $client_id );
  return $self->oauth_error_page( 'unknown client' ) unless $client;

  ## validate redirect_uri against client_id;
  my $urls     = $client->get_all_redirect_urls;
  my %url_hash = map { $_->get_uri => $_ } @{$urls||[]};
  return $self->oauth_error_page( 'incompatible redirect' ) unless exists $url_hash{$path};
  my $url_obj   = $url_hash{$path};
  ## Now get information about Scopes....
  my $scopes          = $client->get_other_adaptor( 'Scope' )->fetch_scopes;
  my %scope_hash      = map { $_->get_code => $_ } @{$scopes};
  my $n_scopes        = @request_scopes;
  @request_scopes     = map { exists $scope_hash{$_} ? $scope_hash{$_} : () } @request_scopes;
  ## The site has requested a scope which we don't know about!
  return $self->oauth_error_page( 'unknown scope' ) unless $n_scopes == @request_scopes;

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
  my $oa_user = $ua->fetch_user_by_username( $self->user->username );
  ## No so we create a new user!
  my $flag = 1;
  if( $oa_user ) {
    $flag = 0;
    if( $self->user->name ne $oa_user->get_name ) {
      $flag = 1;
      $oa_user->set_name(     $self->user->name );
    }
    if( $self->user->auth_method ne $oa_user->get_auth_method ) {
      $flag = 1;
      $oa_user->set_auth_method( $self->user->auth_method );
    }
  } else {
    $oa_user = $ua->create;
    $oa_user->set_username( $self->user->username )
            ->set_name(     $self->user->name )
            ->set_auth_method( $self->user->auth_method )
            ;
  }
  $oa_user->store if $flag;
  $self->oauth_error( 'cannot create user object' ) unless $oa_user->uid;

  ## Now we have a user!
  my $project     = $client->get_project;
  my $pa          = $ca->get_other_adaptor('Permission');
  my $permissions = $pa->get_permissions_by_user_project( $oa_user, $project )||[];
  my %perm_scopes = map { ($_->{'code'} => $scope_hash{ $_->{'code'}} )}
                    @{$permissions};
  my %perm_hash   = map { $_->{'scope_id'} => $_->{'status'} }
                    @{$permissions};
  my %granted_scopes = map { $_->uid => exists $perm_hash{$_->uid} && $perm_hash{$_->uid} eq 'granted' }
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
      ->add_attribute( 'client_id', $client->uid )
      ->add_attribute( 'scope_list', join q( ), map { sprintf '%d %s', $scope_hash{$_}->uid, $granted_scopes{$_} } @request_scopes )
      ->store
      ->action_url_get );
    ## use critic
  }

  my $auth_code    = $oa_user->create_auth_code( $client, $url_obj, $access_type );
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

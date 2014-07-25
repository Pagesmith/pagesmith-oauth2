package Pagesmith::MyForm::OA2::Client;

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

## Admininstration form for objects of type Client
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

use base qw(Pagesmith::MyForm::OA2);
use Pagesmith::Adaptor::OA2::Client;
use Pagesmith::Object::OA2::Client;

sub project {
  my $self = shift;
  return $self->{'_project_defn'};
}

sub fetch_object {
  my $self = shift;

  if( $self->{'object_id'} =~ m{\Aproject-(\d+)}mxsg ) {
    my $project_id = $1;
    my $project = $self->adaptor('Project')->fetch_project( $project_id );
    return unless $project;
    $self->{'_project_defn'} = $project;
    return 1;
  }
  my $db_obj = $self->adaptor( 'Client' )->fetch_client( $self->{'object_id'} );
  return unless $db_obj;
  $self->{'object'}        = $db_obj;
  $self->{'_project_defn'} = $db_obj->get_project;
  return 1;
}

sub cant_create {
  my $self = shift;
  return 'not_logged_in'   unless $self->user->logged_in;
  return 'not_a_developer' unless $self->my_oa_user_id;
  return 'unknown_project' unless $self->project;
  return 'no_permission'   unless $self->project->get_user_id == $self->my_oa_user_id;
  return;
}

sub cant_edit {
  my $self = shift;
  return $self->cant_create;
  ## Check to see if owner....
}


sub populate_object_values {
  my $self = shift;
  return $self unless $self->object && ref $self->object;

  $self->element( 'client_type'  )->set_obj_data( $self->object->get_client_type );
  my @urls = @{$self->object->get_all_urls||[]};
  $self->element( 'redirect_url'       )->set_obj_data(
    join "\n", sort map {$_->get_uri} grep { $_->get_url_type eq 'redirect' } @urls );
  $self->element( 'javascript_origins' )->set_obj_data(
    join "\n", sort map {$_->get_uri} grep { $_->get_url_type eq 'source'   } @urls );
  return $self;
}

sub update_object {
  my $self = shift;
  ## Copy form values back to object...
  $self->object->generate_new_secret if $self->element( 'flush' )->scalar_value eq 'yes';
  $self->object->set_client_type(  $self->element( 'client_type'  )->scalar_value );
  $self->object->store;
  my $current = {};

  ## Store current values - hashed by type/uri
  $current->{$_->get_url_type}{$_->get_uri} = $_ foreach @{$self->object->get_all_urls||[]};

  foreach ( split m{\n}mxs, $self->element('redirect_url')->scalar_value ) {
    my $url = $self->trim($_);
    if( exists $current->{'redirect'}{$url} ) {
      delete $current->{'redirect'}{$url};
    } else {
      $self->object->add_uri( 'redirect', $url )->store;
    }
  }
  foreach ( split m{\n}mxs, $self->element('javascript_origins')->scalar_value ) {
    my $url = $self->trim($_);
    if( exists $current->{'source'}{$url} ) {
      delete $current->{'source'}{$url};
    } else {
      $self->object->add_uri( 'source', $url )->store;
    }
  }
  ## Remove current values if they have been deleted (we haven't seen them in the list above)
  $_->remove foreach map { values %{$_}  } values %{$current};

  return 1;
}

sub create_object {
  my $self = shift;
  ## Creates new object with values from form...
  my $new_obj = $self->adaptor( 'Client' )->create;
     $new_obj->set_project( $self->project );
  $new_obj->set_client_type(  $self->element( 'client_type'  )->scalar_value );
  return unless $new_obj->store();
  foreach ( split m{\n}mxs, $self->element('redirect_url')->scalar_value ) {
    my $url = $self->trim($_);
    $new_obj->add_uri( 'redirect', $url )->store;
  }
  foreach ( split m{\n}mxs, $self->element('javascript_origins')->scalar_value ) {
    my $url = $self->trim($_);
    $new_obj->add_uri( 'source', $url )->store;
  }
  $self->set_object( $new_obj )->set_object_id( $new_obj->uid );
  return 1;
}

sub on_redirect {
  my $self = shift;
  return $self->attribute( 'ref' ) || '/oa2/Dashboard';
}

sub on_confirmation {
  my $self = shift;
  return $self->create_object unless $self->{'object'};
  return $self->update_object;
}

sub initialize_form {
  my $self = shift;

  ## Set up the form...
  ## no critic (LongChainsOfMethodCalls)
  $self->set_title( 'Client' )
       ->force_form_code
       ->add_class(          'form',     'cancel_quietly' )
       ->add_attribute(      'id',        'Client' )
       ->add_attribute(      'method',    'post' )
       ->add_class(          'form',      'check' )          # Javascript validation is enabled
       ->add_class(          'section',   'panel' )          # Form sections are wrapped in panels
       ->add_form_attribute( 'method',    'post' )
       ->set_option(         'validate_before_next' )
       ->set_option(         'no_reset' )
       ->add_class(          'progress',  'panel' )
       ;

## Now add the elements

    $self->add_stage('Client');
    $self->add_section( 'Administration of Client objects' );
    $self->set_next( 'Create' );

      $self->add('Hidden','client_id')
         ->set_optional;

      $self->add('DropDown','client_type')
        ->set_caption( 'Client type' )
          ->set_values( Pagesmith::Object::OA2::Client->dropdown_values_client_type );

      $self->add('Text','redirect_url')
        ->set_optional;

      $self->add('Text','javascript_origins')
        ->set_optional;

      $self->add('CheckBox','flush')
        ->set_caption( 'Check this box to generate a new code/secret' )
        ->set_optional;


  ## use critic

  $self->add_confirmation_stage( 'please_confirm_details' );
    $self->add_section( 'please_confirm_details' );
      $self->add( { 'type' => 'Information', 'caption' => 'Please confirm the details below and press next to update object' } );

    $self->add_readonly_section;
    $self->add_section( 'information' );
      $self->add( { 'type' => 'Information', 'caption' => 'Press "confirm" to update object' } );

  $self->add_redirect_stage( '/oa2/Dashboard' );

  $self->add_error_stage( 'not_logged_in' );
    $self->add_raw_section( '<% File /core/inc/forms/no_user.inc %>' );

  $self->add_error_stage( 'not_a_developer' );
    $self->add_raw_section( '<% File /oa2-core/inc/forms/not_a_developer.inc %>' );

  $self->add_error_stage( 'unknown_project' );
    $self->add_raw_section( '<% File /oa2-core/inc/forms/unknown_project.inc %>' );

  $self->add_error_stage( 'no_permission'  );
    $self->add_raw_section( '<% File /core/inc/forms/no_permission.inc %>' );

  return $self;
}

1;

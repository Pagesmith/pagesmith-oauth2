package Pagesmith::MyForm::OA2::Admin::Project;

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

## Admininstration form for objects of type Project
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
use Pagesmith::Adaptor::OA2::Project;
use Pagesmith::Object::OA2::Project;

sub fetch_object {
  my $self = shift;##
  my $db_obj        = $self->adaptor( 'Project' )->fetch_project( $self->{'object_id'} );
  $self->{'object'} = $db_obj if $db_obj;
  return $db_obj;
}

sub populate_object_values {
  my $self = shift;
  return $self unless $self->object && ref $self->object;

  $self->element( 'name'         )->set_obj_data( [$self->object->get_name]         );
  $self->element( 'description'  )->set_obj_data( [$self->object->get_description]  );
  $self->element( 'homepage'     )->set_obj_data( [$self->object->get_homepage]     );
  $self->element( 'logo'         )->set_obj_data( [$self->object->get_logo]         );
  $self->element( 'privacy'      )->set_obj_data( [$self->object->get_privacy]      );
  $self->element( 'terms'        )->set_obj_data( [$self->object->get_terms]        );
  return $self;
}

sub update_object {
  my $self = shift;
  ## Copy form values back to object...

  $self->object->set_name(         $self->element( 'name'         )->scalar_value );
  $self->object->set_description(  $self->element( 'description'  )->scalar_value );
  $self->object->set_homepage(     $self->element( 'homepage'     )->scalar_value );
  $self->object->set_logo(         $self->element( 'logo'         )->scalar_value );
  $self->object->set_privacy(      $self->element( 'privacy'      )->scalar_value );
  $self->object->set_terms(        $self->element( 'terms'        )->scalar_value );
  $self->object->store;
  return 1;
}

sub create_object {
  my $self = shift;
  ## Creates new object with values from form...
  my $new_obj = $self->adaptor( 'Project' )->create;

  $new_obj->set_name(         $self->element( 'name'         )->scalar_value );
  $new_obj->set_description(  $self->element( 'description'  )->scalar_value );
  $new_obj->set_homepage(     $self->element( 'homepage'     )->scalar_value );
  $new_obj->set_logo(         $self->element( 'logo'         )->scalar_value );
  $new_obj->set_privacy(      $self->element( 'privacy'      )->scalar_value );
  $new_obj->set_terms(        $self->element( 'terms'        )->scalar_value );
  return unless $new_obj->store();
  $self->set_object( $new_obj )->set_object_id( $new_obj->uid );
  return 1;
}

sub initialize_form {
  my $self = shift;

  ## Set up the form...
  ## no critic (LongChainsOfMethodCalls)
  $self->set_title( 'Project' )
       ->force_form_code
       ->add_attribute( 'id',     'Project' )
       ->add_attribute( 'method', 'post' )
       ->add_class(          'form',     'check' )          # Javascript validation is enabled
       ->add_class(          'section',  'panel' )          # Form sections are wrapped in panels
       ->add_form_attribute( 'method',   'post' )
       ->set_option(         'validate_before_next' )
       ->set_option(         'no_reset' )
       ->add_class(          'progress', 'panel' )
       ;

## Now add the elements

    $self->add_stage('Project');
    $self->add_section( 'Administration of Project objects' );
    $self->set_next( 'Create' );

      $self->add('Hidden','project_id')
         ->set_optional;

      $self->add('String','name')
        ->set_caption( 'Name' )
        ->add_class('128');

      $self->add('Text','description')
        ->set_caption( 'Description' );

      $self->add('URL','homepage')
        ->set_caption( 'Homepage' )
        ->add_class('255');

      $self->add('URL','logo')
        ->set_caption( 'Logo' )
        ->add_class('255');

      $self->add('URL','privacy')
        ->set_caption( 'Privacy' )
        ->add_class('255');

      $self->add('URL','terms')
        ->set_caption( 'Terms' )
        ->add_class('255');

  ## use critic

  $self->add_confirmation_stage( 'please_confirm_details' );
    $self->add_section( 'please_confirm_details' );
      $self->add( { 'type' => 'Information', 'caption' => 'Please confirm the details below and press next to update object' } );

    $self->add_readonly_section;

    $self->add_section( 'information' );

      $self->add( { 'type' => 'Information', 'caption' => 'Press "confirm" to update object' } );

  $self->add_final_stage( 'thank_you' );

    $self->add_raw_section( '<p>The object has been updated</p>', 'Thank you' );

    $self->add_readonly_section;

  $self->add_error_stage( 'not_logged_in' );

    $self->add_raw_section( '<% File /core/inc/forms/no_user.inc %>' );

  $self->add_error_stage( 'no_permission'  );

    $self->add_raw_section( '<% File /core/inc/forms/no_permission.inc %>' );

  return $self;
}

1;

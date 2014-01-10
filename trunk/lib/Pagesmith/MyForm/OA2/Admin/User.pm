package Pagesmith::MyForm::OA2::Admin::User;

## Admininstration form for objects of type User
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
use Pagesmith::Adaptor::OA2::User;
use Pagesmith::Object::OA2::User;

sub fetch_object {
  my $self = shift;##
  my $db_obj        = $self->adaptor( 'User' )->fetch_user( $self->{'object_id'} );
  $self->{'object'} = $db_obj if $db_obj;
  return $db_obj;
}

sub populate_object_values {
  my $self = shift;
  return $self unless $self->object && ref $self->object;

  $self->element( 'uuid'      )->set_obj_data( [$self->object->get_uuid]      );
  $self->element( 'username'  )->set_obj_data( [$self->object->get_username]  );
  return $self;
}

sub update_object {
  my $self = shift;
  ## Copy form values back to object...

  $self->object->set_uuid(      $self->element( 'uuid'      )->scalar_value );
  $self->object->set_username(  $self->element( 'username'  )->scalar_value );
  $self->object->store;
  return 1;
}

sub create_object {
  my $self = shift;
  ## Creates new object with values from form...
  my $new_obj = $self->adaptor( 'User' )->create;

  $new_obj->set_uuid(      $self->element( 'uuid'      )->scalar_value );
  $new_obj->set_username(  $self->element( 'username'  )->scalar_value );
  return unless $new_obj->store();
  $self->set_object( $new_obj )->set_object_id( $new_obj->uid );
  return 1;
}

sub initialize_form {
  my $self = shift;

  ## Set up the form...
  ## no critic (LongChainsOfMethodCalls)
  $self->set_title( 'User' )
       ->force_form_code
       ->add_attribute( 'id',     'User' )
       ->add_attribute( 'method', 'post' )
       ->add_class(          'form',     'check' )          # Javascript validation is enabled
       ->add_class(          'section',  'panel' )          # Form sections are wrapped in panels
       ->add_form_attribute( 'method',   'post' )
       ->set_option(         'validate_before_next' )
       ->set_option(         'no_reset' )
       ->add_class(          'progress', 'panel' )
       ;

## Now add the elements

    $self->add_stage('User');
    $self->add_section( 'Administration of User objects' );
    $self->set_next( 'Create' );

      $self->add('Hidden','user_id')
         ->set_optional;

      $self->add('String','uuid')
        ->set_caption( 'Uuid' )
        ->add_class('24');

      $self->add('String','username')
        ->set_caption( 'Username' );

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

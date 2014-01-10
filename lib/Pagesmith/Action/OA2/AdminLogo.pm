package Pagesmith::Action::OA2::AdminLogo;

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

use base qw(Pagesmith::Action::OA2);

sub run {
#@params (self)
## Display admin for table for Project in OA2
  my $self = shift;
  #return $self->no_content unless $self->user->logged_in;
  my $user_adap = $self->adaptor('User')->attach_user( $self->user );
  my $user      = $user_adap->fetch_user_by_username( $self->user->username );
  #return $self->no_content unless $user;
  my $project_id = $self->next_path_info;
  my $project   = $user_adap->project_adaptor->fetch_project( $project_id );
  #return $self->no_content unless $project->get_user_id == $user->uid;

  my $image_details = $project->get_image;
  $self->content_type( 'image/png' )->print( $image_details->{'logo_blob'} )->ok;
}

1;

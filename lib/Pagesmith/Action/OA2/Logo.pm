package Pagesmith::Action::OA2::Logo;

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
  my $self       = shift;
  my $client     = $self->adaptor('Client')->fetch_client_by_code( $self->next_path_info );
  return $self->no_content unless $client;
  my $project    = $client->get_project;
  return $self->no_content unless $project;
  my $img_details = $project->get_image;
  return $self->no_content unless $img_details;

  return $self->content_type( 'image/png' )->print( $img_details->{'logo_blob'} )->ok;
}

1;

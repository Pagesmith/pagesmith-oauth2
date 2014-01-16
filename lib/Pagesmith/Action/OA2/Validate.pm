package Pagesmith::Action::OA2::Validate;

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

use base qw(Pagesmith::Action::OA2);

sub json_error {
  my $self = shift;
  $self->json_print({'error'=>'invalid_token'});
  return $self->bad_request;
}

sub run {
  my $self = shift;

  my $adap = $self->adaptor( 'AccessToken' );
  return $self->json_error unless $adap;

  my $details = $adap->validate_token( $self->param('access_token') );
  return $details ? $self->json_print( $details ) : $self->json_error;
}



1;

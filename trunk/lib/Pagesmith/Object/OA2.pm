package Pagesmith::Object::OA2;

## Base class for objects in OA2 namespace

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


use base qw(Pagesmith::Object);

sub init {
  my( $self, $hashref, $partial ) = @_;
  $self->{'obj'} = {%{$hashref}};
  $self->flag_as_partial if defined $partial && $partial;
  return;
}

sub type {
  my $self = shift;
  my ( $type ) = (ref $self) =~ m{([^:]+)\Z}mxsg;
  return $type;
}

sub get_other_adaptor {
  my( $self, $type ) = @_;
  return $self->adaptor->get_other_adaptor( $type );
}

## Common properties...
sub set_uuid {
  my( $self, $uuid ) = @_;
  $self->{'obj'}{'uuid'}||= $self->safe_uuid;
  return $self;
}

sub get_uuid {
  my $self = shift;
  return $self->{'obj'}{'uuid'};
}
## General stuff!

sub created_at {
  my $self = shift;
  return $self->{'obj'}{'created_at'};
}

sub set_created_at {
  my( $self, $value ) = @_;
  $self->{'obj'}{'created_at'} = $value;
  return $self;
}

sub created_by {
  my $self = shift;
  return $self->{'created_by'}||q(--);
}

sub set_created_by {
  my( $self, $value ) = @_;
  $self->{'obj'}{'created_by'} = $value;
  return $self;
}

sub updated_at {
  my $self = shift;
  return $self->{'obj'}{'updated_at'};
}

sub updated_by {
  my $self = shift;
  return $self->{'obj'}{'updated_by'}||q(--);
}

sub set_updated_at {
  my( $self, $value ) = @_;
  $self->{'obj'}{'updated_at'} = $value;
  return $self;
}

sub set_updated_by {
  my( $self, $value ) = @_;
  $self->{'obj'}{'updated_by'} = $value;
  return $self;
}

sub ip {
  my $self = shift;
  return $self->{'obj'}{'ip'};
}

sub set_ip {
  my( $self, $value ) = @_;
  $self->{'obj'}{'ip'} = $value;
  return $self;
}

sub useragent {
  my $self = shift;
  return $self->{'obj'}{'useragent'};
}

sub set_useragent {
  my( $self, $value ) = @_;
  $self->{'obj'}{'useragent'} = $value;
  return $self;
}

sub project_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'Project' );
}

sub user_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'User' );
}

sub client_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'Client' );
}

sub authcode_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'AuthCode' );
}

sub scope_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'Scope' );
}

sub accesstoken_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'AccessToken' );
}

sub refreshtoken_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'RefreshToken' );
}

sub url_adaptor {
  my $self = shift;
  return $self->get_other_adaptor( 'UrlToken' );
}

1;

__END__

Notes
=====

Base class for all objects - note we overwrite most of the audit functions
as we store the entries in {obj} rather than directly on the object...


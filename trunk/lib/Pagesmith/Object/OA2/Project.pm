package Pagesmith::Object::OA2::Project;

## Class for Project objects in namespace OA2.

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

use English qw(-no_match_vars $PID $INPUT_RECORD_SEPARATOR);

use Image::Size qw(imgsize);
use Image::Magick;
use LWP::Simple qw($ua get);
use POSIX qw(floor ceil);

use Const::Fast qw(const);

const my $MAX_WIDTH    => 160;
const my $MAX_HEIGHT   => 120;
const my $BLUR_EXP     => 1;
const my $SCALE_FACTOR => 4;
const my $BLUR         => 0.25;
const my $TIMEOUT      => 10;

use Pagesmith::ConfigHash qw(proxy_url get_config);

use base qw(Pagesmith::Object::OA2);

## Definitions of lookup constants and methods exposing them to forms.
## ===================================================================

## uid property....
## ----------------

sub uid {
  my $self = shift;
  return $self->{'obj'}{'project_id'};
}

## Property get/setters
## ====================

## Property: project_id
## --------------------

sub get_project_id {
  my $self = shift;
  return $self->{'obj'}{'project_id'};
}

sub set_project_id {
  my ( $self, $value ) = @_;
  if( $value <= 0 ) {
    warn "Trying to set non positive value for 'project_id'\n";
    return $self;
  }
  $self->{'obj'}{'project_id'} = $value;
  return $self;
}

## Property: name
## --------------

sub get_name {
  my $self = shift;
  return $self->{'obj'}{'name'};
}

sub set_name {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'name'} = $value;
  return $self;
}

## Property: description
## ---------------------

sub get_description {
  my $self = shift;
  return $self->{'obj'}{'description'};
}

sub set_description {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'description'} = $value;
  return $self;
}

## Property: homepage
## ------------------

sub get_homepage {
  my $self = shift;
  return $self->{'obj'}{'homepage'};
}

sub set_homepage {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'homepage'} = $value;
  return $self;
}

## Property: logo
## --------------

sub get_logo {
  my $self = shift;
  return $self->{'obj'}{'logo'};
}

sub set_logo {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'logo'} = $value;
  return $self;
}

## Property: privacy
## -----------------

sub get_privacy {
  my $self = shift;
  return $self->{'obj'}{'privacy'};
}

sub set_privacy {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'privacy'} = $value;
  return $self;
}

## Property: terms
## ---------------

sub get_terms {
  my $self = shift;
  return $self->{'obj'}{'terms'};
}

sub set_terms {
  my ( $self, $value ) = @_;
  $self->{'obj'}{'terms'} = $value;
  return $self;
}

## Has "1" get/setters
## ===================

sub get_user {
  my $self = shift;
  return $self->get_other_adaptor( 'User' )->fetch_user_by_project( $self );
}
sub get_user_id {
  my $self = shift;
  return $self->{'obj'}{'user_id'};
}

sub set_user_id  {
  my( $self, $user ) = @_;
  $self->{'obj'}{'user_id'} = ref $user ? $user->uid : $user;
  return $self;
}

## Has "many" getters
## ==================

sub get_all_clients {
  my $self = shift;
  return $self->get_other_adaptor( 'Client' )->fetch_all_clients_by_project( $self );
}

## Relationship getters!
## =====================

## Store method
## =====================

sub store {
  my $self = shift;
  return $self->adaptor->store( $self );
}

## Other fetch functions!
## ======================
## Can add additional fetch functions here! probably hand crafted to get
## the full details...!


sub get_image {
  my $self = shift;
  return $self->adaptor->get_image( $self );
}

sub store_image {
  my $self = shift;
  my $logo_url         = $self->get_logo;
  my $compressed_image = q();
  my $width            = 0;
  my $height           = 0;
  if( $logo_url ) {
    $ua->proxy( [qw(http https)], proxy_url );
    $ua->timeout( $TIMEOUT );
    my $image_contents = get $logo_url;
    return unless $image_contents;

    my $filename = get_config('RealTmp') . $PID . q(.) . time;
    if( open my $fh, q(>), $filename ) {
      print {$fh} $image_contents; ## no critic (RequireChecked)
      close $fh; ## no critic (RequireChecked)
      my ( $img_x, $img_y ) = imgsize( $filename );
      if( $img_x && $img_y ) {
        my $image = Image::Magick->new;
        $image->Read( $filename );
        if( $img_x > $MAX_WIDTH || $img_y > $MAX_HEIGHT ) {
          my $sf_x = ceil( $img_x / $MAX_WIDTH );
          my $sf_y = ceil( $img_y / $MAX_HEIGHT );
          my $sf   = $sf_x > $sf_y ? $sf_x : $sf_y;
          $image->Resize(
            'filter'   => 'Cubic',
            'blur'     => $BLUR,
            'geometry' => sprintf '%dx%d>', floor( $img_x/$sf ), floor( $img_y/$sf ),
          );
        }
        $image->Write( "$filename.png" );
        my $return = system 'advpng', '-4', '-z', "$filename.png";
        ( $img_x, $img_y ) = imgsize( "$filename.png" );
        if( open my $fh, q(<), "$filename.png" ) {
          local $INPUT_RECORD_SEPARATOR = undef;
          $compressed_image = <$fh>;
          close $fh; ## no critic (RequireChecked)
          $width  = $img_x;
          $height = $img_y;
          unlink "$filename.png";
        }
      }
      unlink $filename;
    }
  }
  $self->adaptor->store_image( $self, $width, $height, $compressed_image );
  return $self;
}

1;
__END__

Purpose
-------

Object classes are the basis of the Pagesmith OO abstraction layer


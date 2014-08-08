package Pagesmith::Object::OA2::Project;

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


## Author         : James Smith <js5@sanger.ac.uk>
## Maintainer     : James Smith <js5@sanger.ac.uk>
## Created        : 30th Jul 2014

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
use Pagesmith::Utils::ObjectCreator qw(bake);

## Last bit - bake all remaining methods!
bake();

sub fetch_clients {
  my $self = shift;
  return $self->get_other_adaptor( 'Client' )->fetch_clients_by_project( $self );
}

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

sub revoke {
  my( $self, $user ) = @_;
  return $self->adaptor->revoke( $self, $user );
}

sub remove {
  my( $self, $user ) = @_;
  return $self->adaptor->revoke( $self, $user ) + ## removes authcode, 
         $self->get_other_adaptor( 'Permission' )->revoke( $self, $user );
}

1;

__END__

Purpose
=======

Object classes are the basis of the Pagesmith OO abstraction layer

Notes
=====

What methods do I have available to me...!
------------------------------------------

This is an auto generated module. You can get a list of the auto
generated methods by calling the "auto generated"
__PACKAGE__->auto_methods or $obj->auto_methods!

Overriding methods
------------------

If you override an auto-generated method a version prefixed with
std_ will be generated which you can use within the package. e.g.

sub get_name {
  my $self = shift;
  my $name = $self->std_get_name;
  $name = 'Sir, '.$name;
  return $name;
}


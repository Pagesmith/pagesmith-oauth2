package Pagesmith::Adaptor::OA2;

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

## Base adaptor for objects in OA2 namespace

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

use base qw(Pagesmith::AdaptorMethods Pagesmith::Adaptor);
use Pagesmith::Utils::ObjectCreator qw(bake_base_adaptor);

sub attach_user_web {
## Attach user for security/audit purposes...
  my( $self, $user )  = @_;
  if( $user->username ) {
    $self->{'_user_details'} = {
      'id' => $self->sv('select user_id from user where auth_method = ? and username = ?',
                          $user->auth_method, $user->uid )||0,
      'username' => $user->username,
    };
  } else {
    $self->{'_user_details'} = { 'id' => 0, 'username' => '-web-' };
  }
  return $self;
}

bake_base_adaptor();

1;

__END__
Notes
-----


package Pagesmith::MyForm::OA2;

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

## Base class for all forms in "OA2"

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

use base qw(Pagesmith::MyForm Pagesmith::Support::OA2);

sub render_extra {
  my $self = shift;
  return '<% OA2_Navigation -ajax %>';
}

sub my_oa_user_id {
  my $self = shift;
  unless( exists $self->{'my_oa_user_id'} ) {
    my $u = $self->adaptor('User')->fetch_user_by_auth_method_username(
             $self->user->auth_method, $self->user->uid );
    $self->{'my_oa_user_id'} = $u ? $u->uid : 0;
  }
  return $self->{'my_oa_user_id'};
}

1;

__END__
Notes
-----

This is the generic Form code for all the code with objects in the
namespace "OA2".


package Pagesmith::Action::OA2;

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

## Base class for actions in OA2 namespace

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

use base qw(Pagesmith::Action Pagesmith::Support::OA2);

use Const::Fast qw(const);
const my $MESSAGES => {
  'incompatible redirect' =>
    'The configuration of the application precludes returing to the requested URL',
  'unknown scope'         =>
    'The application is requesting an unknown scope',
};

sub oauth_error_page {
  my ( $self, $msg ) = @_;
  $msg = $MESSAGES->{$msg} if exists $MESSAGES->{$msg};
  return $self->html->wrap( 'OAuth2 error', sprintf '<p>%s</p>', $msg )->ok;
}

sub my_wrap {
  my( $self, @pars ) = @_;
  return $self->html->wrap( @pars )->ok;
}

sub run {
  my $self = shift;
  return $self->redirect( '/oa2/Dashboard' );
}

1;

__END__
Notes
-----

This is the generic Action code for all the code with objects in the
namespace "OA2". Just set run to redirect to dashboard!


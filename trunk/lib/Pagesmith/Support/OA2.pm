package Pagesmith::Support::OA2;

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

## Base class for actions/components in OA2 namespace

use base qw(Pagesmith::ObjectSupport);
use Pagesmith::Utils::ObjectCreator qw(bake);

sub me {
  my ( $self, $create ) = @_;
  ## no critic (LongChainsOfMethodCalls)
  return $self->{'me'}
    ||= $self->adaptor('User')->fetch_user_by_auth_method_username( $self->user->auth_method, $self->user->uid )
    ||  ( $create ? $self->adaptor('User')->create->set_auth_method( $self->user->auth_method )
                                                  ->set_email(       $self->user->email       )
                                                  ->set_name(        $self->user->name        )
                                                  ->set_username(    $self->user->uid         )->store : undef );
  ## use critic
}

bake();


1;
__END__

Purpose
-------

The purpose of the Pagesmith::Support::OA2 module is to
place methods which are to be shared between the following modules:

* Pagesmith::Action::OA2
* Pagesmith::Component::OA2

Common functionality can include:

* Default configuration for tables, two-cols etc
* Database adaptor calls
* Accessing configurations etc

Some default methods for these can be found in the
Pagesmith::ObjectSupport from which this module is derived:

  * adaptor( $type? ) -> gets an Adaptor of type Pagesmith::Adaptor::OA2::$type
  * my_table          -> simple table definition for a table within the site
  * admin_table       -> simple table definition for an admin table (if different!)
  * me                -> user object (assumes the database being interfaced has a
                         User table keyed by "email"...


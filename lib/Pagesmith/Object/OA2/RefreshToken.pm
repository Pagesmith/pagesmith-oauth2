package Pagesmith::Object::OA2::RefreshToken;

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

use base qw(Pagesmith::Object::OA2);
use Pagesmith::Utils::ObjectCreator qw(bake);
use List::MoreUtils qw(any);

sub has_scope {
  my ( $self, $scope_code ) = @_;
  return any { $_->get_code eq $scope_code } $self->scopes;
}

sub fetch_scopes {
   my $self = shift;
   $self->{'scopes'} = {map { $_->uid => $_ } @{$self->get_other_adaptor('Scope')->fetch_scopes_by_refreshtoken( $self )}};
   return $self;
}

sub scopes {
  my $self = shift;
  $self->fetch_scopes unless exists $self->{'scopes'};
  return values %{$self->{'scopes'}};
}

sub scopes_ref {
  my $self = shift;
  return $self->{'scopes'};
}

sub expires_in {
  my $self = shift;
  return $self->{'obj'}{'expires_at_ts'} - time;
}

sub revoke {
  my( $self, $user ) = @_;
  return $self->adaptor->revoke( $self, $user );
}

## Last bit - bake all remaining methods!
bake();

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


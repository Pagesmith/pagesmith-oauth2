package Pagesmith::MyForm::OA2::Admin::Project;

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

## Admininstration form for objects of type Project
## in namespace OA2

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

use base qw(Pagesmith::MyForm::OA2::Admin);

sub object_type {
#@return (string) the type of object (within the namespace!)
  return 'Project';
}

sub entry_names {
#@return (string+) - an array of names - these are used in the create_object/update_object code

  return qw(name description homepage logo privacy terms user_id);
}

## no critic (LongChainsOfMethodCalls)
sub initialize_form {
  my $self = shift;

  $self->admin_init;

    my $users           = $self->adaptor( 'User' )->fetch_all_users;

    ## Unique_ID
    $self->add(           'Hidden',                'project_id' )->set_optional;

    $self->add(           'String',                'name' );
    $self->add(           'Text',                  'description' );
    $self->add(           'URL',                   'homepage' );
    $self->add(           'URL',                   'logo' );
    $self->add(           'URL',                   'privacy' );
    $self->add(           'URL',                   'terms' );
    $self->add(           'DropDown',              'user_id' )
         ->set_firstline(   '== select ==' )
         ->set_caption(     'User' )
         ->set_values(      [ map { { 'value' => $_->uid, 'name' => $_->get_user_id } } @{$users} ] );

  $self->add_end_stages;
  return $self;
}
## use critic

1;
__END__
Notes
-----

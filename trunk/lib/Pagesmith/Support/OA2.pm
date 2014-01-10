package Pagesmith::Support::OA2;

## Base class shared by actions/components in OA2 namespace

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

use Const::Fast qw(const);

const my $DEFAULT_PAGE => 25;

## Support functions to generate HTML blocks
## -----------------------------------------

sub my_table {
#@params (self)
#@return (Pagesmith::HTML::Table)
## Default table setup for site...

  my $self = shift;
  return $self->table
    ->add_classes(qw(before))
    ->make_sortable
    ->set_filter
    ->set_export( [qw(txt csv xls)] )
    ->set_pagination( [qw(10 25 50 100 all)], $DEFAULT_PAGE );
}

## If you wish to use a different "table" class for admin tables you can define it here!

sub admin_table {
#@params (self)
#@return (Pagesmith::HTML::Table)
## Default "admin" table setup for site...

  my $self = shift;
  return $self->my_table;
}

## User wrapper methods! to base db adaptor (and all db adaptors)...
## -----------------------------------------------------------------

sub attach_user {
  my $self = shift;
  $self->adaptor->attach_user( {
    'username' => $self->user->username,
    'name'     => $self->user->name,
    'type'     => 'web',
  });
  return $self;
}


## Support functions to be shared by actions/components e.g. database adaptors...
## ------------------------------------------------------------------------------
##
## This is the default "adaptor" call which currently bases the adaptor purely
## on the type of object - to allow more complex rules and caching can add
## other properties to this method! e.g. site name, species, sub-name...

sub adaptor {
#@params (self) (sting object type)
#@return (Pagesmith::HTML::Table)
## Return a database adaptor for objects of supplied type - getting from pool
## so we don't duplicate.

  my ( $self, $type ) = @_;

  unless( exists $self->{'_base_adaptor'} ) {
    $self->{'_base_adaptor'} = $self->get_adaptor( 'OA2' );
  }
  ## Failed so we stop here!
  return unless $self->{'_base_adaptor'};

  ## This is a raw adaptor so return it!
  return $self->{'_base_adaptor'} unless defined $type;

  unless( exists $self->{'_adaptors'}{$type} ) {
    $self->{'_adaptors'}{$type} = $self->{'_base_adaptor'}->get_other_adaptor( $type );
  }

  return $self->{'_adaptors'}{$type};
}


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

$self->adaptor additional notes
-------------------------------

Note if we modify this to using class rather than instance storage we will
need to handle the user slighlty differently as it can't be cached in quite
the same way - as long as user is a real user object then it should be OK
as we can clear it when we create the base adaptor!
{_base_adaptor} should be an instance object BUT can reference a package
object
 - do my $base_adaptor; in module defn!
 - then line below becomes:
     - $self->{'_base_adaptor'} ||= $base_adaptor ||= $self->get... 


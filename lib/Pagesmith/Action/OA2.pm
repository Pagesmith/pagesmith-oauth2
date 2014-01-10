package Pagesmith::Action::OA2;

## Base class for actions in OA2 namespace

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

use base qw(Pagesmith::Action Pagesmith::Support::OA2);

sub my_wrap {
  my( $self, @pars ) = @_;
  return $self->html->wrap( @pars )->ok;
}

1;

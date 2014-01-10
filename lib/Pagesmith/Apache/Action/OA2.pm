package Pagesmith::Apache::Action::OA2;

## Apache handler for OA2 action classes for oa2

## Author         : js5 (James Smith)
## Maintainer     : js5 (James Smith)
## Created        : 2014-01-08
## Last commit by : $Author $
## Last modified  : $Date $
## Revision       : $Revision $
## Repository URL : $HeadURL $

use strict;
use warnings;
use utf8;

use version qw(qv);our $VERSION = qv('0.1.0');

use Pagesmith::Apache::Action qw(simple_handler);

sub handler {
  my $r = shift;
  return simple_handler( 'oa2', 'OA2', $r );
}

1;

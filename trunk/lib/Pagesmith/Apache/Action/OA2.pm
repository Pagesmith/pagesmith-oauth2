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

use Pagesmith::Apache::Action qw(my_handler);

sub handler {
  my $r = shift;
  # return($path_munger_sub_ref,$request)
  # see Pagesmith::Action::_handler to find out how this works
  # briefly:  munges the url path using the sub {} defined here
  # to get the action module
  # then calls its run() method and returns a status value

  return my_handler(
    sub {
      my ( $apache_r, $path_info ) = @_;
      if( $path_info->[0] eq 'oa2' ) {
        shift @{$path_info};
        if( @{$path_info} ) {
          $path_info->[0] = 'OA2_'.$path_info->[0];
        } else {
          unshift @{$path_info}, 'OA2';
        }
      }
      return;
    },
    $r,
  );
}

1;

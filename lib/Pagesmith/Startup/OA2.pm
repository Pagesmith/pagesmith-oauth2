package Pagesmith::Startup::OA2;

## Apache start-up script to include site specific lib
## directories, and preload any modules required by the
## system - to speed up process of producing children
## and to maximise amount of shared memory.

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

use version qw(qv); our $VERSION = qv('0.1.0');

use File::Basename qw(dirname);
use Cwd qw(abs_path);

BEGIN { unless( exists $ENV{q(SINGLE_LIB_DIR)} && $ENV{q(SINGLE_LIB_DIR)} ) {
  my $dir = dirname(dirname(dirname(abs_path(__FILE__))));
  my $has_cgi = -d dirname($dir).'/cgi';
  if( -d $dir ) {
    unshift @INC, $dir;
    $ENV{'PERL5LIB'} = qq($dir:$ENV{'PERL5LIB'}) if $has_cgi; ## no critic (LocalizedPunctuationVars)
  }
  $dir = dirname($dir).'/ext-lib';
  if( -d $dir ) {
    unshift @INC, $dir;
    $ENV{'PERL5LIB'} = qq($dir:$ENV{'PERL5LIB'}) if $has_cgi; ## no critic (LocalizedPunctuationVars)
  }
}}

## Now we need to include here a list of preloaded use statements if required!

# use Pagesmith::Action::OA2
# use Pagesmith::Component::OA2
# use Pagesmith::Support::OA2
# use Pagesmith::Apache::Action::OA2

1;

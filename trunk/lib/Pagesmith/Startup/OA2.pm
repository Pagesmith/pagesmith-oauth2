package Pagesmith::Startup::OA2;

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
use Pagesmith::ConfigHash qw(set_default);

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

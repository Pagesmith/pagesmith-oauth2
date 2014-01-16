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

use Const::Fast qw(const);
const my $MESSAGES => {
  'incompatible redirect' =>
    'The configuration of the application precludes returing to the requested URL',
  'no state string'       =>
    'The configuraiton of the application requires a state string to be passed',
  'unknown scope'         =>
    'The application is requesting an unknown scope',
};


use base qw(Pagesmith::Action Pagesmith::Support::OA2);

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

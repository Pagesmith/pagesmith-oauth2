package Pagesmith::MyForm::OA2;

## Base form for namespace OA2

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


use base qw(Pagesmith::MyForm Pagesmith::Support::OA2);

sub my_oa_user_id {
  my $self = shift;
  unless( exists $self->{'my_oa_user_id'} ) {
    my $u = $self->adaptor('User')->fetch_user_by_username( $self->user->username );
    $self->{'my_oa_user_id'} = $u ? $u->uid : 0;
  }
  return $self->{'my_oa_user_id'};
}
1;

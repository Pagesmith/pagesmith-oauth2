package Pagesmith::Support::OA2::Script;

## ScriptBase class shared by actions/components in OA2 namespace

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

use base qw(Pagesmith::Support Pagesmith::Support::OA2);

use Pagesmith::Core qw(user_info);

sub attach_user {
  my $self = shift;
  my $userinfo = user_info();
  $self->adaptor->attach_user( {
    'username' => $userinfo->{'username'},
    'name'     => $userinfo->{'name'},
    'type'     => 'script',
  });
  return $self;
}

1;

__END__

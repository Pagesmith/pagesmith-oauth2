package Pagesmith::Model::OA2;

#+----------------------------------------------------------------------
#| Copyright (c) 2014 Genome Research Ltd.
#| This file is part of the User account management extensions to
#| Pagesmith web framework.
#+----------------------------------------------------------------------
#| The User account management extensions to Pagesmith web framework is
#| free software: you can redistribute it and/or modify it under the
#| terms of the GNU Lesser General Public License as published by the
#| Free Software Foundation; either version 3 of the License, or (at
#| your option) any later version.
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

## Base class shared by actions/components in Sanger::AdvCourses namespace

## Author         : James Smith <js5>
## Maintainer     : James Smith <js5>
## Created        : Thu, 23 Jan 2014
## Last commit by : $Author$
## Last modified  : $Date$
## Revision       : $Revision$
## Repository URL : $HeadURL$

use strict;
use warnings;
use utf8;

use version qw(qv); our $VERSION = qv('0.1.0');

use Pagesmith::Utils::ObjectCreator qw(bake);

use Const::Fast qw(const);

const my $CLIENT_TYPES => [
  [ 'web'       => 'Web application' ],
  [ 'service'   => 'Service application' ],
  [ 'installed' => 'Embedded application' ],
];
const my $DEFAULT_CLIENT_TYPE => 'web';

const my $ACCESS_TYPES => [
  [ 'online'    => 'On-line' ],
  [ 'offline'   => 'Off-line' ],
];
const my $DEFAULT_ACCESS_TYPE => 'online';

const my $URL_TYPES => [
  [ 'redirect' => 'Redirect' ],
  [ 'source'   => 'Source' ],
  [ 'user'     => 'User' ],
];
const my $DEFAULT_URL_TYPE => 'redirect';

bake( {
  'mail_domain' => 'sanger.ac.uk',
  'relationships' => {
    'Permission' => {
      'objects' => [
        'user_id'    => 'User',
        'project_id' => 'Project',
        'scope_id '  => 'Scope',
      ],
      'additional' => [
        'allowed' => { 'type' => 'Boolean', 'default' => 'yes' },
      ],
    },
    'Property' => {
      'objects' => [
        'user_id'  => 'User',
        'scope_id' => 'Scope',
      ],
      'additional' => [
        'value' => { 'type' => 'string' },
      ],
    },
  },
  'objects' => {
    'Project' => {
      'audit' => { qw(datetime both user_id both ip create useragent create) },
      'properties' => [
        'project_id'  => 'uid',
        'code'        => { 'type' => 'uuid', 'length' => 24 },
        'name'        => { 'type' => 'string', 'length' => 128 },
        'description' => { 'type' => 'text', },
        'homepage'    => { 'type' => 'url',    'length' => 255 },
        'logo'        => { 'type' => 'url',    'length' => 255 },
        'privacy'     => { 'type' => 'url',    'length' => 255 },
        'terms'       => { 'type' => 'url',    'length' => 255 },
        'logo_height' => { 'type' => 'int', },
        'logo_width'  => { 'type' => 'int', },
      ],
      'admin' => { 'by' => 'admin' },
      'related' => [
        'user_id' => { 'to' => 'User' },
        'clients' => { 'from' => 'Client' },
      ],
    },
    'Client' => {
      'audit' => { qw(datetime both user_id both ip create useragent create) },
      'properties' => [
        'client_id' => 'uid',
        'code'      => { 'type' => 'uuid', 'length' => 24 },
        'secret'    => { 'type' => 'uuid', 'length' => 24 },
        'client_type' => { 'type' => 'enum', 'values' => $CLIENT_TYPES, 'default' => $DEFAULT_CLIENT_TYPE },
      ],
      'admin' => { 'by' => 'admin' },
      'related' => [
        'project_id' => { 'to' =>   'Project' },
        'urls'       => { 'from' => 'Url' },
      ],
    },
    'Url' => {
      'audit' => { qw(datetime both user_id both ip create useragent create) },
      'properties' => [
        'url_id'   => 'uid',
        'url_type' => { 'type' => 'enum', 'values' => $URL_TYPES, 'default' => $DEFAULT_URL_TYPE },
        'uri'      => { 'type' => 'url', 'length' => '255' },
      ],
      'admin' => { 'by' => 'admin' },
      'remove' => 1,
      'related' => [
        'client_id' => { 'to' =>   'Client' },
      ],
    },
    'Scope' => {
      'properties' => [
        'scope_id'     => 'uid',
        'code'         => { 'type' => 'string', 'unique' => 1, 'length' => 128 },
        'name'         => { 'type' => 'string', 'length' => 128 },
        'description'  => { 'type' => 'text' },
      ],
      'admin' => { 'by' => 'superadmin' },
    },
    'AuthCode' => {
      'properties' => [
        'authcode_id' => 'uid',
        'uuid'        => { 'type' => 'uuid' },
        'expires_at'  => { 'type' => 'datetime' },
        'access_type' => { 'type' => 'enum', 'values' => $ACCESS_TYPES, 'default' => $DEFAULT_ACCESS_TYPE },
        'session_key' => { 'type' => 'string', 'length' => 128 },
      ],
      'related' => [
        'user_id'   => { 'to' =>   'User'  },
        'client_id' => { 'to' =>   'Client'  },
        'url_id'    => { 'to' =>   'Url'  },
        'scope'     => { 'from' => 'Scope' },
      ],
      'admin' => { 'by' => 'superadmin' },
    },
    'AccessToken' => {
      'properties' => [
        'accesstoken_id' => 'uid',
        'uuid'        => { 'type' => 'uuid' },
        'expires_at'  => { 'type' => 'datetime' },
        'session_key' => { 'type' => 'string', 'length' => 128 },
      ],
      'related' => [
        'user_id'   => { 'to' =>   'User'  },
        'client_id' => { 'to' =>   'Client', 'derived' => { 'project_id' => 'project_id' } },
        'refreshtoken_id'    => { 'to' =>   'RefreshToken'  },
        'scope'     => { 'from' => 'Scope' },
      ],
      'admin' => { 'by' => 'superadmin' },
    },
    'RefreshToken' => {
      'properties' => [
        'refreshtoken_id' => 'uid',
        'uuid'        => { 'type' => 'uuid' },
        'expires_at'  => { 'type' => 'datetime' },
      ],
      'related' => [
        'user_id'   => { 'to' =>   'User'  },
        'client_id' => { 'to' =>   'Client', 'derived' => { 'project_id' => 'project_id' }  },
        'accesstokens' => { 'from' =>   'AccessToken'  },
        'scope'     => { 'from' => 'Scope' },
      ],
      'admin' => { 'by' => 'superadmin' },
    },
    'User' => {
      'audit'      => { qw(datetime both user_id both ip create useragent create) },
      'properties' => [
        'user_id'      => 'uid',
        'uuid'         => { 'type' => 'uuid', 'length' => 24, },
        'auth_method'  => { 'type' => 'string', 'length' => 64, },
        'username'     => { 'type' => 'string', 'length' => 128, },
        'name'         => { 'type' => 'string', 'length' => 128, },
        'email'        => { 'type' => 'string', 'length' => 128, },
        'developer'    => { 'type' => 'boolean', 'default' => 'no' },
        'admin'        => { 'type' => 'boolean', 'default' => 'no' },
        'superadmin'   => { 'type' => 'boolean', 'default' => 'no' },
      ],
      'admin' => { 'by' => 'superadmin' },
      'fetch_by' => [
        { 'unique' => 1, 'keys' => [ 'auth_method', 'username'  ] },
      ],
      'related' => [
        'projects' => { 'from' => 'Project' },
      ],
    },
  },
} );

1;

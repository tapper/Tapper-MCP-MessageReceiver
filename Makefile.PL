use strict;
use warnings;

use inc::Module::Install;

name     'Tapper-MCP-MessageReceiver';
all_from 'lib/Tapper/MCP/MessageReceiver.pm';
author   'AMD OSRC Tapper Team <tapper@amd64.org>';
license  'perl';

build_requires 'Test::More';
build_requires 'IO::Socket::INET';

author_requires 'Module::Install::WriteAll';

requires 'Tapper::Model'  => "3.000002";
requires 'Tapper::Config' => "3.000002";
requires 'YAML::Syck'     => "1.17";
requires 'AnyEvent';
requires 'EV';

install_script glob('bin/*');

auto_install;

WriteAll;


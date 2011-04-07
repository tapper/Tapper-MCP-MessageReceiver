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

requires 'App::Daemon';
requires 'Tapper::Model' => "3.000010";
requires 'Tapper::Config' => "3.000010";
requires 'Tapper::Base' => "3.000010";
requires 'Moose'             => "1.24";
requires 'YAML::Syck'        => "1.17";
requires 'AnyEvent';
requires 'EV';

install_script glob('bin/*');

repository 'git://github.com/amd/Tapper-MCP-MessageReceiver.git';
bugtracker 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tapper-MCP-MessageReceiver';

auto_install;

WriteAll;


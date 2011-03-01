use inc::Module::Install;

name     'Tapper-MCP-MessageReceiver';
all_from 'lib/Tapper/MCP/MessageReceiver.pm';
author   'OSRC SysInt Team <osrc-sysint@elbe.amd.com>';
license  'perl';

build_requires 'Test::More';
build_requires 'IO::Socket::INET';

author_requires 'Module::Install::WriteAll';

requires 'Tapper::Model'  => "3.000001";
requires 'Tapper::Config' => "3.000001";
requires 'YAML::Syck'     => 0;
requires 'AnyEvent';
requires 'EV';

install_script glob('bin/*');

auto_install;

WriteAll;


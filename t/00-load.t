#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Tapper::MCP::MessageReceiver' );
}

diag( "Testing Tapper::MCP::MessageReceiver $Tapper::MCP::MessageReceiver::VERSION, Perl $], $^X" );

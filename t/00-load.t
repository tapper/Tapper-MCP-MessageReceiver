#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Tapper::MessageReceiver' );
}

diag( "Testing Tapper::MessageReceiver $Tapper::MessageReceiver::VERSION, Perl $], $^X" );

#!perl

use warnings;
use strict;

use Tapper::Config;

use IO::Socket::INET;
use Test::More;
use YAML::Syck;
use Tapper::Model 'model';

use Tapper::MCP::MessageReceiver;
use English;

use File::Temp qw/  tempdir /;

my $dir = tempdir( CLEANUP => 1 );
$ENV{TAPPER_MSG_RECEIVER_PIDFILE} = "$dir/pid";

my $status = qx($EXECUTABLE_NAME bin/tapper-mcp-messagereceiver start 2>&1);
like($status, qr/Start succeeded/, 'Daemon started');

# give server time to settle
sleep 10;


# eval makes sure the server is stopped at the end. Please leave it intakt
eval {
        my $sender = IO::Socket::INET->new(PeerAddr => 'localhost',
                                           PeerPort => Tapper::Config::subconfig->{mcp_port},
                                          );
        ok(($sender and $sender->connected), 'Connected to server');
        $sender->say(YAML::Syck::Dump({testrun_id => 4, state => 'start_install'}));
        sleep 10;                # give server time to do his work
        my $messages = model('TestrunDB')->resultset('Message')->search({testrun_id => 4});
        is($messages->count, 1, 'One message for testrun 4 in DB');
        is_deeply($messages->first->message, {testrun_id => 4, state => 'start_install'}, 'Expected message in DB');

};

$status = qx($EXECUTABLE_NAME bin/tapper-mcp-messagereceiver stop 2>&1);
like($status, qr/Stop succeeded/, 'Daemon stopped');


done_testing;

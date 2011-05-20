#!perl

use warnings;
use strict;

use Tapper::Config;

use IO::Socket::INET;
use Test::More;
use YAML::Syck;
use Tapper::Model 'model';
use Test::Fixture::DBIC::Schema;
use Tapper::Schema::TestTools;

use Tapper::MCP::MessageReceiver;
use English "-no_match_vars";

use File::Temp qw/  tempdir /;

construct_fixture( schema  => testrundb_schema,  fixture => 't/fixtures/testrundb/testrun_empty.yml' );



my $dir = tempdir( CLEANUP => 1 );
$ENV{TAPPER_MSG_RECEIVER_PIDFILE} = "$dir/pid";

my $status;
$status = qx($EXECUTABLE_NAME -Ilib bin/tapper-mcp-messagereceiver start 2>&1);
is($status, '', 'Daemon start without error');

$status    = qx($EXECUTABLE_NAME -Ilib bin/tapper-mcp-messagereceiver status 2>&1);
my $status_hash = YAML::Syck::Load($status);
is(ref($status_hash), 'HASH', 'Starting daemon returned YAML');
is($status_hash->{Running}, 'yes', 'Daemon started');

{
        no warnings;
        # give server time to settle
        sleep ($ENV{TAPPER_SLEEPTIME} || 10);
}


# eval makes sure the server is stopped at the end. Please leave it intakt
eval {
        my $sender = IO::Socket::INET->new(PeerAddr => 'localhost',
                                           PeerPort => Tapper::Config::subconfig->{mcp_port},
                                          );
        ok(($sender and $sender->connected), 'Connected to server');
        $sender->say("GET /state/start_install/testrun_id/4/ HTTP/1.0\r\n\r\n");
        $sender->close();
        {
                no warnings;
                # give server time to do his work
                sleep( $ENV{TAPPER_SLEEPTIME} || 10);
        }
        my $messages = model('TestrunDB')->resultset('Message')->search({testrun_id => 4});
        is($messages->count, 1, 'One message for testrun 4 in DB');
        is_deeply($messages->first->message, {testrun_id => 4, state => 'start_install'}, 'Expected message in DB');
        is($messages->first->type, , 'state', 'Expected status in DB');

};
fail($@) if $@;

eval {
        my $sender = IO::Socket::INET->new(PeerAddr => 'localhost',
                                           PeerPort => Tapper::Config::subconfig->{mcp_port},
                                          );
        ok(($sender and $sender->connected), 'Connected to server');
        $sender->say("GET /action/reset/host/bullock HTTP/1.0\r\n\r\n");
        $sender->close();
        {
                no warnings;
                # give server time to do his work
                sleep( $ENV{TAPPER_SLEEPTIME} || 10);
        }
        my $messages = model('TestrunDB')->resultset('Message')->search({type => 'action'});
        is($messages->count, 1, 'One message for type action in DB');
        is_deeply($messages->first->message, {action => 'reset', host => 'bullock'}, 'Expected message in DB');
        is($messages->first->type, , 'action', 'Expected status in DB');

};
fail($@) if $@;


$status = qx($EXECUTABLE_NAME -Ilib bin/tapper-mcp-messagereceiver stop 2>&1);
is($status, '', 'Daemon stopped without error');


done_testing;

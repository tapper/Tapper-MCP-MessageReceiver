#!perl

use warnings;
use strict;

use Tapper::Config;

use IO::Socket::INET;
use Test::More;
use YAML::Syck;
use Tapper::Model 'model';

use Tapper::MCP::MessageReceiver;


my $pidfile = '/tmp/pidfile';
# block for local @ARGV
{
        local @ARGV =('start');
        my $serv = Tapper::MCP::MessageReceiver->new_with_options(pidfile=>$pidfile);
        $serv->run();
        like($serv->status_message, qr/Start succeeded/, 'Daemon started');
}

# give server time to settle
sleep 2;


# eval makes sure the server is stopped at the end. Please leave it intakt
eval {
        my $sender = IO::Socket::INET->new(PeerAddr => 'localhost',
                                           PeerPort => Tapper::Config::subconfig->{mcp_port},
                                          );
        ok(($sender and $sender->connected), 'Connected to server');
        $sender->say(YAML::Syck::Dump({testrun_id => 4, state => 'start_install'}));
        sleep 1;                # give server time to do his work
        my $messages = model('TestrunDB')->resultset('Message')->search({testrun_id => 4});
        is($messages->count, 1, 'One message for testrun 4 in DB');
        is_deeply($messages->first->message, {testrun_id => 4, state => 'start_install'}, 'Expected message in DB');

};

# block for local @ARGV;
{
        local @ARGV =('stop');
        my $serv = Tapper::MCP::MessageReceiver->new_with_options(pidfile=>$pidfile);
        $serv->run();
        like($serv->status_message, qr/Stop succeeded/, 'Daemon stopped');
}


done_testing;

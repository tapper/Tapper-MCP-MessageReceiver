#!perl

use warnings;
use strict;

use Artemis::Config;

use IO::Socket::INET;
use Test::More;
use YAML::Syck;
use Artemis::Model 'model';

use Tapper::MessageReceiver;

my $pid = fork();
die "Can not fork:$!" if not defined $pid;


if ($pid == 0) {
        my $serv = Tapper::MessageReceiver->new;
        $serv->run();
        exit;
} else {
        sleep 1; # give time for server to start
        my $sender = IO::Socket::INET->new(PeerAddr => 'localhost',
                                           PeerPort => Artemis::Config::subconfig->{mcp_port},
                                           
                                          );
        die "No connection to server" unless $sender;
        ok($sender->connected, 'Connected to server');
        $sender->say(YAML::Syck::Dump({testrun_id => 4, state => 'start_install'}));
        sleep 1; # give server time to do his work
        my $messages = model('TestrunDB')->resultset('Message')->search({testrun_id => 4});
        is($messages->count, 1, 'One message for testrun 4 in DB');
        is_deeply($messages->first->message, {testrun_id => 4, state => 'start_install'}, 'Expected message in DB');

        kill 15, $pid;
        waitpid($pid, 0);
}

done_testing();

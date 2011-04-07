package Tapper::MCP::MessageReceiver;

use AnyEvent::Socket;
use EV;
use IO::Handle;
use Log::Log4perl;
use Moose;
use YAML::Syck;


extends 'Tapper::Base';
use Tapper::Config;
use Tapper::Model 'model';

use warnings;
use strict;

=head1 NAME

Tapper::MCP::MessageReceiver - Tapper - Message receiver for Tapper MCP

=cut

our $VERSION = '3.000010';

=head1 SYNOPSIS


    use Tapper::MCP::MessageReceiver;

    my $daemon = Tapper::MCP::MessageReceiver->new_with_options(pidfile=>'/tmp/pid');
    $daemon->run;

=cut

=head1 METHODS

=head2 

=cut

use 5.010;

sub run {
        my ($self) = @_;
        Log::Log4perl->init(Tapper::Config->subconfig->{files}{log4perl_cfg});
        $self->log->info("Started MessageReceiver daemon");

        my $port = Tapper::Config::subconfig->{mcp_port} || 1337;
        tcp_server undef, $port, sub {
                my ($fh, $host, $port) = @_;
                return unless $fh;
                my $condvar = AnyEvent->condvar;

                my $message = '';
                my $read_watcher; 
                $read_watcher = AnyEvent->io
                  (
                   fh   => $fh,
                   poll => 'r',
                   cb   => sub{
                           my $received_bytes = sysread $fh, $message, 1024, length $message;
                           if ($received_bytes <= 0) {
                                   undef $read_watcher;
                                   $condvar->send($message);
                           }
                   }
                  );
                my $data = $condvar->recv;
                my $yaml = YAML::Syck::Load($data);
                if ((ref $yaml eq 'HASH') and ($yaml->{testrun} or $yaml->{testrun_id})) {
                        my $tr_id = $yaml->{testrun} // $yaml->{testrun_id};
                        my $db = model('TestrunDB')->resultset('Message')->new({testrun_id => $tr_id,
                                                                                message => $yaml});
                        $db->insert;
                } else {
                        $self->log->error("Received message '$data' from '$host' without testrun ID. ".
                                          "Calculating testrun IDs from host names is not yet supported.");
                }
        };
        EV::loop;

}



=head1 AUTHOR

AMD OSRC Tapper Team, C<< <tapper at amd64.org> >>



=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tapper::MCP::MessageReceiver



=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2008-2011 AMD OSRC Tapper Team, all rights reserved.

This program is released under the following license: freebsd


=cut

1; # End of Tapper::MCP::MessageReceiver

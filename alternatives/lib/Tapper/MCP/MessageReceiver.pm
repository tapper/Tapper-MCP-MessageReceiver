package Tapper::MCP::MessageReceiver;

use warnings;
use strict;
use English '-no_match_vars';
use 5.010;


use IO::Socket::INET::Daemon;
use Moose;

extends 'Tapper::Base';

use Tapper::Config;
use Tapper::Model 'model';
use YAML::Syck;

our $data;

=head1 NAME

Tapper::MessageReceiver - Message receiver for Tapper!

=cut

our $VERSION = '1.000001';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Tapper::MessageReceiver;

    my $foo = Tapper::MessageReceiver->new();
    $foo->run;


=cut

sub add{
        my $io = shift;
        if ($data->{$io->peerhost}) {
                say STDERR $io->peerhost, " is already connected";
                return;
        }
        $data->{$io->peerhost} = '';
        return 1;
}

sub data{
        my ($io, $host) = @_;

        if (my $new_data = $io->getline) {
                $data->{$io->peerhost} .= $new_data;
                return 1;
        } else {
                return;
        }
}

sub remove{
        my $io = shift;
        my $yaml = YAML::Syck::Load($data->{$io->peerhost});
        if ($yaml->{testrun} or $yaml->{testrun_id}) {
                my $tr_id = $yaml->{testrun} // $yaml->{testrun_id};
                my $db = model('TestrunDB')->resultset('Message')->new({testrun_id => $tr_id,
                                                                        message => $yaml});
                $db->insert;
        }
        delete $data->{$io->peerhost};
}


=head1 FUNCTIONS


=head2 run

Start the server.

=cut

sub run
{
        my ($self) = @_;

        my $dir = Tapper::Config::subconfig->{paths}{message_receiver_path};
        my $retval = $self->makedir($dir);
        my $pidfile = "$dir/pidfile";
        open my $fh, ">", $pidfile or die "Can not open '$pidfile':$!";
        print $fh $PID;
        close $fh;

        open (STDOUT, ">>", "$dir/output.stdout") or print(STDERR "Can't open output file $dir/output.stdout: $!"),exit 1;
        open (STDERR, ">>", "$dir/output.stderr") or print(STDERR "Can't open output file $dir/output.stderr: $!"),exit 1;



        my $host = IO::Socket::INET::Daemon->new(
                port =>  Tapper::Config::subconfig->{mcp_port},
                callback => {
                        add => \&add,
                        remove => \&remove,
                        data => \&data,
                },
        );
        $host->run;

}



=head1 AUTHOR

AMD OSRC Tapper Team, C<< <tapper at amd64.org> >>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tapper::MessageReceiver

=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008-2011 AMD OSRC Tapper Team, all rights reserved.

This program is released under the following license: freebsd

=cut

1; # End of Tapper::MessageReceiver

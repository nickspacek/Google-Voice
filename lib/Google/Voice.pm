package Google::Voice;

use Moose;
use Google::Voice::Agent;

our $VERSION = '0.01';

has 'agent' => (
	is => 'rw',
	isa => 'Google::Voice::Agent',
	builder => '_build_agent',
	handles => [ qw( login logout send_sms get_feed ) ]
);

sub _build_agent {
	my $self = shift;
	
	return Google::Voice::Agent->new_with_config(
		configfile => 'urls.yml'
	);
}

=head1 NAME

Google::Voice - Interface to Google Voice.

=head1 SYNOPSIS

    use Google::Voice;

    my $gv = Google::Voice->new;
    die 'Couldn't login to Google Voice.'
        unless $gv->login( 'email', 'password' );

    my $number = '15551234567';
    my $message = 'message';

    # There is no error reporting yet.
    print 'Message sent!' if $gv->send_sms( $number, $message );

=head1 DESCRIPTION

Google::Voice provides a simple API for Google Voice.

Current features:

=over 4

=item * Send SMS

=item * Fetch raw feeds

=back

Future features:

=over 4

=item * Download voicemail/messages

=item * Change settings

=item * Make calls

=back

This module is based on the Python library, PyGoogleVoice
(http://code.google.com/p/pygooglevoice/).

=head1 AUTHOR

    Nick Spacek
    nick.spacek@gmail.com
    http://identi.ca/nickspacek

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

perl(1).

=cut

1;


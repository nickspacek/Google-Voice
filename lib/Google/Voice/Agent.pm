package Google::Voice::Agent;

use Moose;
with 'MooseX::SimpleConfig';

use Config::Any;
use LWP::UserAgent;
use JSON;

has 'agent' => (
	is => 'rw',
	isa => 'LWP::UserAgent',
	builder => '_build_agent'
);

has 'base_url' => (
	is => 'rw',
	isa => 'Str',
	required => 1
);

has 'pages' => (
	traits => [ 'Hash' ],
	is => 'rw',
	isa => 'HashRef[HashRef[Str]]',
	default => sub { {} },
	handles => {
		set_page => 'set',
		get_page => 'get',
		has_page => 'exists'
	}
);

has 'special' => (
	is => 'rw',
	isa => 'Str',
	builder => '_build_special',
	lazy_build => 1
);

sub _build_agent {
	my $self = shift;
	
	my $ua = LWP::UserAgent->new(
		cookie_jar => { file => '/tmp/c.tmp', auto_save => 1 },
		agent => 'Google::Voice',
		requests_redirectable => [ qw( GET POST HEAD ) ]
	);
	
	return $ua;
}

sub _build_special {
	my $self = shift;
	
	# TODO: Verify logged in
	my $res = $self->_request( 'inbox' );
	return '' unless $res && $res->is_success;

	return '' unless $res->content =~ /'_rnr_se': '(.+)'/;
	return $1;
}

sub _page {
	my ( $self, $page ) = @_;
	
	return undef unless $self->has_page( $page );

	my %page_hash = %{ $self->get_page( $page ) };
	$page_hash{ url } = $self->base_url . $page_hash{ url }
		unless $page_hash{ url } =~ '^https?';
	return \%page_hash;
}

# TODO: Figure out the errors
sub _request {
	my ( $self, $page, @params ) = @_;
	
	my $method = @params ? 'post' : 'get';
	
	return undef unless $self->has_page( $page );
	my $page_ref = $self->_page( $page );

	push @params, _rnr_se => $self->special if $page_ref->{ needs_special };

	my $response = $self->agent->$method(
		$page_ref->{ url }, @params ? \@params : () );
	return $response;
}

sub login {
	my ( $self, $email, $password ) = @_;
	
	my $res = $self->_request( 'login' );
	return 0 unless $res->is_success;
	
	return 0 unless $res->content =~ /name="GALX"\s+value="(.+)"/;
	$res = $self->_request(
		'login',
		Email => $email,
		Passwd => $password,
		GALX => $1
	);
	
	return $res->is_success ? 1 : 0;
}

sub logout {
	my $self = shift;
	
	my $res = $self->_request( 'logout' );
	return $res->is_success ? 1 : 0;
}

sub send_sms {
	my ( $self, $number, $text ) = @_;
	# TODO: Verify only 160 chars?
	my $res = $self->_request(
		'sms',
		phoneNumber => $number,
		text => $text
	);
	
	return 0 unless $res->is_success;
	my $json = from_json( $res->content );
	return $json->{ ok } ? 1 : 0;
}

sub get_feed {
	my ( $self, $feed ) = @_;
	
	my $res = $self->_request( "xml_$feed" );
	return $res && $res->is_success ? $res->content : undef;
}

1;

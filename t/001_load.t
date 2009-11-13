# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Google::Voice' ); }

my $object = Google::Voice->new ();
isa_ok ($object, 'Google::Voice');



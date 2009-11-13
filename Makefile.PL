
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Google::Voice',
    VERSION_FROM => 'lib/Google/Voice.pm',
    AUTHOR       => 'Nick Spacek (nick.spacek@gmail.com)',
    ABSTRACT     => 'Interface to Google Voice.',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                     'Moose' => 0.92,
                     'Config::Any' => 0.17,
                     'LWP::UserAgent' => 5.829,
                     'JSON' => 2.15
                    },
);

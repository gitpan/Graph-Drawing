use 5.005;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Graph::Drawing',
    VERSION_FROM => 'lib/Drawing.pm',
    PREREQ_PM    => {
        'Carp' => 0,
        'Test::More' => 0,
        'Graph::Weighted' => 0,
    },
    ($] >= 5.005
        ? (ABSTRACT_FROM => 'lib/Drawing.pm',
           AUTHOR        => 'Gene Boggs <gene@cpan.org>')
        : ()
    ),
);
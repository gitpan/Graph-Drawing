use 5.005;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Graph::Drawing',
    VERSION_FROM => 'lib/Graph/Drawing.pm',
    PREREQ_PM    => {
        'Carp' => 0,
        'Test::More' => 0,
        'Graph::Weighted' => 0,
        'GD' => 0,  # ugh
    },
    ($] >= 5.005
        ? (ABSTRACT_FROM => 'lib/Graph/Drawing.pm',
           AUTHOR        => 'Gene Boggs <gene@cpan.org>')
        : ()
    ),
);

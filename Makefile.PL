#!/usr/bin/perl
use strict;
use warnings;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Graph::Drawing',
    VERSION_FROM => 'lib/Graph/Drawing.pm',
    PREREQ_PM    => {},
    ($] >= 5.005
        ? (ABSTRACT_FROM => 'lib/Graph/Drawing.pm',
           AUTHOR        => 'Gene Boggs <gene@cpan.org>')
        : ()
    ),
);

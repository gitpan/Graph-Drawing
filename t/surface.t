use Test::More 'no_plan';#tests => 1;

BEGIN { use_ok 'Graph::Drawing::Surface' };

my $g = Graph::Drawing::Surface->new();
isa_ok $g, 'Graph::Drawing::Surface';

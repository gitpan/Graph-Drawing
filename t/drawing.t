use Test::More 'no_plan';#tests => 1;

BEGIN { use_ok 'Graph::Drawing' };

my $g = Graph::Drawing->new();
isa_ok $g, 'Graph::Drawing';

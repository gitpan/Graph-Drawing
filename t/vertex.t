use Test::More 'no_plan';#tests => 1;

BEGIN { use_ok 'Graph::Drawing::Vertex' };

my $g = Graph::Drawing::Vertex->new();
isa_ok $g, 'Graph::Drawing::Vertex';

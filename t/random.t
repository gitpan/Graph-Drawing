use Test::More 'no_plan';#tests => 1;

BEGIN { use_ok 'Graph::Drawing::Random' };

my $g = Graph::Drawing::Random->new();
isa_ok $g, 'Graph::Drawing::Random';

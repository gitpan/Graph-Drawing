use Test::More 'no_plan';#tests => 1;

BEGIN { use_ok 'Graph::Drawing::Vertex' };

my $v;

eval {
    $v = Graph::Drawing::Vertex->new();
};
isa_ok $v, 'Graph::Drawing::Vertex';
ok !$@, 'created with no arguments';

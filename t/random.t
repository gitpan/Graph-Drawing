use Test::More 'no_plan';#tests => 1;

BEGIN { use_ok 'Graph::Drawing::Random' };

my $g;

eval {
    $g = Graph::Drawing::Random->new();
};
isa_ok $g, 'Graph::Drawing::Random';
ok !$@, 'created with no arguments';

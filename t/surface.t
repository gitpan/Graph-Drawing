use Test::More 'no_plan';#tests => 1;

BEGIN { use_ok 'Graph::Drawing::Surface' };

my $s;

eval {
    $s = Graph::Drawing::Surface->new();
};
isa_ok $s, 'Graph::Drawing::Surface';
ok !$@, 'created with no arguments';

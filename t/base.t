use Test::More 'no_plan';#tests => 1;

BEGIN { use_ok 'Graph::Drawing::Base' };

my $g;

eval {
    $g = Graph::Drawing::Base->new();
};
isa_ok $g, 'Graph::Drawing::Base';
ok !$@, 'created with no arguments';

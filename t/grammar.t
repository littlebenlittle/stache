use v6;

use Test;
use Stache::Base;

class Unit {
    has Str $.text;
    has Str $.name;
}

my @units = [
    Unit.new(
        :text('{test}'),
    ),
];

plan @units.elems;

for @units {
    .text ~~ Stache::Base::Grammar::{'&text'};
    is $/.Str, .text, .name // "'{.text.chomp.lines.first}' ~~ Stache::Base::Grammar::\{'&text'\}";
}

done-testing;


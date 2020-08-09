use v6;

use Test;
use Stache :Internals;

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
    .text ~~ Stache::Grammar::{'&text'};
    is $/.Str, .text, .name // "'{.text.chomp.lines.first}' ~~ Stache::Grammar::\{'&text'\}";
}

done-testing;


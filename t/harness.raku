use v6;

use Stache :Internals;
use Test;

my @tests = [
    {
        inp  => 'other-test',
        outp => 'other-test',
        name => 'parse raw template',
    },
    {
        inp  => '{{ say "test"  }}',
        outp => 'test',
        name => 'parse lone raku template',
    },
    {
        inp  => 'another-{{ say "test"  }}',
        outp => 'another-test',
        name => 'parse mixed raku template',
    },
    {
        inp  => 'hello {{ # nil }} world',
        outp => 'hello  world',
        name => 'trim none',
    },
    {
        inp  => 'hello {{> say "X" }} world',
        outp => 'hello Xworld',
        name => 'trim right',
    },
    {
        inp  => 'hello {{< say "X" }} world',
        outp => 'helloX world',
        name => 'trim left',
    },
    {
        inp  => 'hello {{- say "X" }} world',
        outp => 'helloXworld',
        name => 'trim both',
    },
];

plan @tests.elems;
is Stache::Grammar.parse($_<inp>).made, $_<outp>, $_<name> for @tests;

q:to/EOF/,
{{
    use-context { name => 'ben', jobid => 123 }
}}
name: {{ .name }}
jobid: {{ .jobid }}
{{ close-context $values }}
EOF

use v6;

use Stache :Internals;
use Test;

my @tests = [
    {
        inp  => 'this is a test',
        outp => 'this is a test',
        name => 'parse raw template',
    },
    {
        inp  => '{{ print "test"  }}',
        outp => 'test',
        name => 'parse lone raku template',
    },
    {
        inp  => 'another-{{ print "test"  }}',
        outp => 'another-test',
        name => 'parse mixed raku template',
    },
    {
        inp  => 'hello {{ # nil }} world',
        outp => 'hello  world',
        name => 'trim none',
    },
    {
        inp  => 'hello {{> print "X" }} world',
        outp => 'hello Xworld',
        name => 'trim right',
    },
    {
        inp  => 'hello {{< print "X" }} world',
        outp => 'helloX world',
        name => 'trim left',
    },
    {
        inp  => 'hello {{- print "X" }} world',
        outp => 'helloXworld',
        name => 'trim both',
    },
];

plan @tests.elems;
is render-template($_<inp>), $_<outp>, $_<name> for @tests;

done-testing;

q:to/EOF/,
{{
    use-context { name => 'ben', jobid => 123 }
}}
name: {{ .name }}
jobid: {{ .jobid }}
{{ close-context $values }}
EOF

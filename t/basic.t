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
    {
        inp  => q:to/EOF/,
        {{>
        my $values = %( name => 'ben', jobid => 123 );
        my $things = ('here', 'they', 'are');
        }}

        name: {{ print $values.name }}
        jobid: {{ print $values.jobid }}
        things: {{ print $things }}
        EOF
        outp => q:to/EOF/,
        name: ben
        jobid: 123
        things: here they are
        EOF
        name => 'test setting and using values',
    },
];

plan @tests.elems;
is render-template($_<inp>), $_<outp>, $_<name> for @tests;

done-testing;


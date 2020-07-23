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
        inp  => '{{ print "test";  }}',
        outp => 'test',
        name => 'parse lone raku template',
    },
    {
        inp  => 'another-{{ print "test";  }}',
        outp => 'another-test',
        name => 'parse mixed raku template',
    },
    {
        inp  => 'hello {{ print "X"; }} world',
        outp => 'hello X world',
        name => 'trim none',
    },
    {
        inp  => 'hello {{> print "X"; }} world',
        outp => 'hello Xworld',
        name => 'trim right',
    },
    {
        inp  => 'hello {{< print "X"; }} world',
        outp => 'helloX world',
        name => 'trim left',
    },
    {
        inp  => 'hello {{- print "X"; }} world',
        outp => 'helloXworld',
        name => 'trim both',
    },
    {
        inp  => q:to/EOF/,
        {{>
        my $values = %( name => 'ben', jobid => 123 );
        my $thing = 'here it is';
        }}

        name: {{ say $values<name>; }}
        jobid: {{ say $values<jobid>; }}
        things: {{ say $thing; }}
        EOF
        outp => q:to/EOF/.chomp,
        name: ben
        jobid: 123
        things: here it is
        EOF
        name => 'test setting and using values',
    },
];

plan @tests.elems;
is render-template($_<inp>), $_<outp>, $_<name> for @tests;

done-testing;


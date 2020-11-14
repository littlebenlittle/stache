use v6;

use Stache :Internals;
use Test;

class Unit {
    has Str $.inp;
    has Str $.outp;
    has Str $.name;
}

my @tests = [
    Unit.new(
        inp  => 'this is a test',
        outp => 'this is a test',
    ),
    Unit.new(
        inp  => '{{ print "test";  }}',
        outp => 'test',
    ),
    Unit.new(
        inp  => 'another-{{ print "test";  }}',
        outp => 'another-test',
    ),
    Unit.new(
        inp  => 'hello {{ print "X"; }} world',
        outp => 'hello X world',
    ),
    Unit.new(
        inp  => 'hello {{> print "X"; }} world',
        outp => 'hello Xworld',
    ),
    Unit.new(
        inp  => 'hello {{< print "X"; }} world',
        outp => 'helloX world',
    ),
    Unit.new(
        inp  => 'hello {{- print "X"; }} world',
        outp => 'helloXworld',
    ),
    Unit.new(
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
        name => 'setting and using values',
    ),
    Unit.new(
        inp  => q:to/EOF/,
        a template {{ say 'with { }'; }}
        EOF
        outp => q:to/EOF/.chomp,
        a template with { }
        EOF
    ),
];

plan @tests.elems;
try {
    is render-template(.inp), .outp, .name // .inp.chomp.lines.first;
    CATCH { .note; .resume; }
} for @tests;

done-testing;


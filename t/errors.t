use v6;

use Test;
use Stache;

class Unit {
	has $.name;
    has $.template;
    has %.ctx;
    has $.expects;
}

my @units = [
    Unit.new(
        name => 'mismatched endwith/endfor',
        template => q:to/EOT/,
            {{ for items }}
            shape: {{ .shape }}
            genus: {{ .holes }}
            {{ endwith }}
            EOT
        ctx => %(
            items => [
                %(
                    shape => 'sphere',
                    holes => 0,
                ),
                %(
                    shape => 'torus',
                    holes => 1,
                ),
            ],
        ),
        expects => 'mismatched structure close {{ endwith }}: line 4',
    ),
    Unit.new(
        name => 'wrong type in with context',
        template => q:to/EOT/,
            {{ with A }}
            {{ A.b }}
            {{ endwith }}
            EOT
        ctx => %( A => 'test'),
        expects => 'expected "A" to be Hash, got Str',
    ),
    Unit.new(
        name => 'unknown structure block',
        template => q:to/EOT/,
            {{ INVALID A }}
            {{ A.b }}
            {{ endINVALID }}
            EOT
        ctx => %( A => 'test'),
        expects => 'could not parse template',
    ),
];

plan @units.elems;

for @units {
    my $err-msg;
    try {
        Stache::render(.template, |.ctx);
        CATCH {
            when X::AdHoc { $err-msg = .message }
            default { .rethrow }
        }
    }
    note "no exception was thrown" unless $err-msg;
    is $err-msg, .expects, .name;
}

done-testing;


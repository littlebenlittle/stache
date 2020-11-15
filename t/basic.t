use v6;

use Test;
use Stache::Base;

class Unit {
    has $.tmpl;
    has $.expects;
    has $.args;
    has $.name;
}

my @units = [
    Unit.new(
        tmpl => q:to/EOS/,
            class {{ class-name }} {
                has {{ type }} $.head;
                has {{ class-name }} $.tail;
                submethod BUILD(:$!head, :$!tail) {}
                method empty { self.bless }
                method append($head, {{ class-name }} $tail) {
                    self.bless(head => $head, tail => $tail)
                }
            }
            EOS
        args => {
            type       => 'Nat',
            class-name => 'List-of-Nat',
        },
        expects => q:to/EOS/,
            class List-of-Nat {
                has Nat $.head;
                has List-of-Nat $.tail;
                submethod BUILD(:$!head, :$!tail) {}
                method empty { self.bless }
                method append($head, List-of-Nat $tail) {
                    self.bless(head => $head, tail => $tail)
                }
            }
            EOS
        name => 'list class template',
    ),
];

plan @units.elems;

my &render = new-renderer(
    text   => -> $raw, |c { $raw },
    interp => -> $raw, |c {
        grammar Interpolation {
            token TOP { [ <alnum> || <+[-_]> ]+ }
            class Actions {
                method TOP($/) {
                    my $s = $/.Str;
                    my $found = False;
                    for c<args>.keys -> $key {
                        if $key eq $s {
                            make c<args>{$key};
                            $found = True;
                        }
                    }
                    make "ERROR: {$s}" if not $found;
                }
            }
            method parse($target, Mu :$actions = Actions) {
                callwith($target, :actions($actions));
            }
        }
        my $outp = Interpolation.parse($raw.trim).made;
        die "couldn't parse «$raw»" unless $outp;
        $outp;
    },
);
is &render(.tmpl, args => .args), .expects, .name for @units;

done-testing;


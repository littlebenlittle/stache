use v6;

use Test;

use Stache::Renderer;

class Unit {
    has $.tmpl;
    has $.args;
    has $.expects;
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

is Stache::Renderer::basic(.tmpl, |.args), .expects, .name for @units;

done-testing;



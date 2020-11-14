use v6;

use Test;
use Stache::Basic;

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

grammar Interpolation {
    token TOP { .+ }
    class Actions { method TOP($/) { make 'bingo!' } }
    method parse($target, Mu :$actions = Actions, |c) {
		say c<args>;
        callwith($target, :actions($actions), |c);
    }
}

my &render = new-stache(
	text   => -> $raw, %args { $raw },
	interp => -> $raw, %args {
		Interpolation.parse($raw, args => %args).made
	},
);
is &render(.tmpl, args => .args), .expects, .name for @units;

done-testing;


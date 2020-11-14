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
			class {{ className }} {
				has {{ type }} $.head;
				has {{ className }} $.tail;
				submethod BUILD(:$!head, :$!tail) {}
				method empty { self.bless }
				method append($head, {{ className }} $tail) {
					self.bless(head => $head, tail => $tail)
				}
			}
			EOS
		args => {
			type       => 'Nat',
			className => 'List-of-Nat',
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

my &render = new-stache(
	text   => -> $raw, |c { $raw },
	interp => -> $raw, |c {
		grammar Interpolation {
			token TOP { [ <alnum> || <+[-_]> ]+ }
			class Actions {
				method TOP($/) {
					make 'bingo!'
				}
			}
			method parse($target, Mu :$actions = Actions, |c) {
				callwith($target, :actions($actions));
			}
		}
		my $outp = Interpolation.parse($raw.trim, |c).made;
		die "couldn't parse «$raw»" unless $outp;
		$outp;
	},
);
is &render(.tmpl, args => .args), .expects, .name for @units;

done-testing;


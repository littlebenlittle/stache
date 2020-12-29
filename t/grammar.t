use v6;

use Test;
use META6::Query;
use YAMLish;
use Stache;

my $root-dir = META6::Query::root-dir $?FILE;
my $fixt-dir = $root-dir.add('resources').add('fixtures').add('grammar');

my $tmpl    = $fixt-dir.add('template.txt').slurp;
my $expects = $fixt-dir.add('expects.txt').slurp;
my %ctx     = load-yaml $fixt-dir.add('values.yaml').slurp;

plan 1;

is Stache::render($tmpl, |%ctx), $expects, 'render a simple template';

done-testing;


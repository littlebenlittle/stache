use v6;

use Test;
use META6::Query;

my $root-dir = META6::Query::root-dir $?FILE;
my $lib-dir  = $root-dir.add('lib');
my $fixt-dir = $root-dir.add('resources').add('fixtures');
my $exe      = $root-dir.add('bin').add('stache');

my $tmpl    = $fixt-dir.add('template.txt').Str;
my $values  = $fixt-dir.add('values.yaml').Str;
my $expects = $fixt-dir.add('expects.txt').slurp;

my $proc = run « $*EXECUTABLE -I $lib-dir $exe --values=$values $tmpl », :out;

say $proc.out;

done-testing;


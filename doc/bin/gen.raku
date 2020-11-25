#!env raku

use META6::Query;
use Stache;

my $root-dir = META6::Query::root-dir $?FILE;
my $lib-dir = $root-dir.add('lib');
my $doc-dir = $root-dir.add('doc');
my $example-dir = $root-dir.add('examples');
my $template = $doc-dir.add('README.tmpl.md').slurp;

my %args = %();
race for $example-dir.dir.grep(* ~~ / .* '.raku' $ /) {
    my @cmd = « $*EXECUTABLE -I $lib-dir $_ »;
    $_.basename ~~ / (.*) '.raku' $ /;
    my $proc = run @cmd, :out;
    %args{$/[0] ~ '-example'} = $_.slurp.trim;
    %args{$/[0] ~ '-example-output'} = $proc.out.slurp.trim;
}

my $content = Stache::render($template, |%args);

my $readme = $root-dir.add('README.md');
$readme.spurt($content.trim ~ "\n\n");

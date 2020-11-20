#!env raku

use META6::Query;
use Stache::Renderer;

my $root-dir = META6::Query::root-dir $?FILE;
my $lib-dir = $root-dir.add('lib');
my $doc-dir = $root-dir.add('doc');
my $example-dir = $root-dir.add('examples');
my $template = $doc-dir.add('README.tmpl.md').slurp;

my %args = %();
race for ('basic', 'extending') {
    my $example-file = $example-dir.add($_ ~ '.raku').absolute.IO;
    my @cmd = « $*EXECUTABLE -I $lib-dir $example-file »;
    my $proc = run @cmd, :out;
    %args{$_ ~ '-example'} = $example-file.slurp.trim;
    %args{$_ ~ '-example-output'} = $proc.out.slurp.trim;
}

my $content = Stache::Renderer::basic($template, |%args);

my $readme = $root-dir.add('README.md');
$readme.spurt($content.trim ~ "\n\n");

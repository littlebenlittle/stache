#!env raku


use Stache::Renderer;

my $root-dir = $?FILE.IO.dirname.IO.dirname.IO.dirname.IO;
my $doc-dir = $root-dir.add('doc');
my $example-dir = $root-dir.add('examples');
my $template = $doc-dir.add('README.tmpl.md').slurp;

my $content = Stache::Renderer::basic(
    $template,
    basic-example => $example-dir.add('basic.raku').slurp.trim,
);

my $readme = $root-dir.add('README.md');
$readme.spurt($content.trim ~ "\n");

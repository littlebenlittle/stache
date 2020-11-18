#!env raku


use Stache::Renderer;

my $root-dir = $?FILE.IO.dirname.IO.dirname.IO.dirname.IO;
my $doc-dir = $root-dir.add('doc');
my $example-dir = $root-dir.add('examples');
my $template = $doc-dir.add('README.tmpl.md').slurp;

my $basic-example-file = $example-dir.add('basic.raku').absolute.IO;
say $basic-example-file;
my $basic-example = $basic-example-file.slurp.trim;
my @cmd = « $*EXECUTABLE $basic-example-file »;
my $proc = run @cmd, :out, :err;
my $basic-example-output = $proc.out.slurp.trim;

my $content = Stache::Renderer::basic(
    $template,
    :$basic-example,
    :$basic-example-output,
);

my $readme = $root-dir.add('README.md');
$readme.spurt($content.trim ~ "\n\n");

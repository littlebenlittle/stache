
use Stache;

my $template = q:to/EOT/;
{{ with A }}
name: {{ .name }}
type: {{ .type }}
{{ endwith }}
EOT

say Stache::render(
    $template,
    A => %(
        name => '楽',
        type => 'language',
    ),
);

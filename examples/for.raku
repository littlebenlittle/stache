
use Stache;

my $template = q:to/EOT/;
{{ for items }}
shape: {{ .shape }}
genus: {{ .holes }}

{{ endfor }}
EOT

say Stache::render(
    $template,
    items => [
        %(
            shape => 'sphere',
            holes => 0,
        ),
        %(
            shape => 'torus',
            holes => 1,
        ),
    ],
);

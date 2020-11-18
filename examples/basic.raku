use Stache::Renderer;

my $template = q:to/EOT/;
say '> # This is some {{ lang }} code';
say '> {{ code }}';
say {{ code }};
EOT

say Stache::Renderer::basic(
    $template,
    lang => 'Raku',
    code => '1 + 1',
);

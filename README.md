# Stache

Stache is an extensible mustache-style templating engine.

## Basic Use

Raku script:

```text
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
```

Output:

```raku
say '> # This is some Raku code';
say '> 1 + 1';
say 1 + 1;
```


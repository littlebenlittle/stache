# Stache

Stache is an extensible mustache-style templating engine.

## Basic Use

Raku script:

```raku
use Stache;

my $template = q:to/EOT/;
say '> # This is some {{ lang }} code';
say '> {{ code }}';
say {{ code }};
EOT

say Stache::render(
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


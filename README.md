# Stache

> **nb**: This project currently has an unstable API! Minor version changes may break existing code.

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

```txt
say '> # This is some Raku code';
say '> 1 + 1';
say 1 + 1;
```

## Structure Blocks

### With Blocks

Raku script:

```raku
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
```

Output:

```txt
name: 楽
type: language
```

### For Blocks

Raku script:

```raku
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
```

Output:

```txt
shape: sphere
genus: 0

shape: torus
genus: 1
```


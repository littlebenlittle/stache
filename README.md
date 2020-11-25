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

```raku
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


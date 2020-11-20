# Stache

Stache is an extensible mustache-style templating engine.

## Basic Use

Raku script:

```raku
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

```text
say '> # This is some Raku code';
say '> 1 + 1';
say 1 + 1;
```

## Extending

Writing your own parser extension is simple. Just specify how the text inside and outside the staches should be rendered.

Raku script:

```raku
use Stache;

my &render = Stache::new-renderer(
    body   => -> $raw, | { $raw },
    stache => -> $raw, | {
        $raw.trim.subst(/was/, 'can be').subst(/hard/, 'easy!')
    }
);

say &render(q:to/EOT/).trim;
Extending templating engines {{ was }} {{ hard }}
EOT
```

Output:

```text
Extending templating engines can be easy!
```


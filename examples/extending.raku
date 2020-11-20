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

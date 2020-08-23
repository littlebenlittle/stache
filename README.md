
# Stache ;}

Stache is an overly-featured raku template system.

## Example

```yaml
# template.yaml
{{-
my $values = { name => 'ben', jobid => 123 };
my @things = ('here', 'they', 'are');
}}

name: {{ say $values<name>; }}
jobid: {{ say $values<jobid>; }}
things: [{{ print @things.map({"'$_'"}).join(', '); }}]
```

```bash
rakudo -I ./lib bin/stache -I=./lib template.yaml
```

```yaml
name: ben
jobid: 123
things: ['here', 'they', 'are']
```


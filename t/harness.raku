use v6;

use Stache :Internals;
use Test;

is Stache::Block.new(
    body    => 'はじめまして世界さん',
    trim    => Nil,
    context => 'raw',
).render, 'はじめまして世界さん', 'raw context';

is Stache::Block.new(
    body    => 'はじめまして',
    trim    => Nil,
    context => 'raw',
    next-block => Stache::Block.new(
        body    => 'say "世界"',
        trim    => Nil,
        context => 'raku',
        next-block => Stache::Block.new(
            body    => 'say "さん"',
            trim    => Nil,
            context => 'raku',
        )
    )
).render, 'はじめまして世界さん', 'raku context';

# is Stache::Grammar.parse('other-test').made, 'other-test', 'parse raw template';
is Stache::Grammar.parse('{{ say "test"  }}').made, 'test', 'parse raku template';
# is Stache::Grammar.parse('another-{{ say "test"  }}').made, 'another-test', 'parse mixed';

# is Stache::Grammar.parse('hello {{  # none }} world').made, 'hello  world';
# is Stache::Grammar.parse('hello {{< # pre  }} world').made, 'hello world';
# is Stache::Grammar.parse('hello {{> # post }} world').made, 'hello world';
# is Stache::Grammar.parse('hello {{- # both  }} world').made, 'helloworld';


q:to/EOF/,
{{
    use-context { name => 'ben', jobid => 123 }
}}
name: {{ .name }}
jobid: {{ .jobid }}
{{ close-context $values }}
EOF

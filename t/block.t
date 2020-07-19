
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


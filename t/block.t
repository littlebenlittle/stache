use v6;

use Stache :Internals;
use Test;

plan 2;

is Stache::Body-Block.new(
    body     => 'はじめまして世界さん',
    trim-tag => Stache::trim::none,
).render, q:to/EOT/, 'render body block';
print q:to/EOS/.chomp;
はじめまして世界さん
EOS
EOT

is Stache::Tmpl-Block.new(
    body    => 'print "はじめまして世界さん"',
    trim-tag => Stache::trim::none,
).render, "print \"はじめまして世界さん\";\n", 'render tmpl block';

done-testing;


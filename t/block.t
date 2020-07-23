use v6;

use Stache :Internals;
use Test;

my @tests = [
    {
        inp  => Text-Block.new(:text('はじめましてお世界さん')),
        outp => q:to/EOT/,
            print q:to/EOS/.chomp;
            はじめましてお世界さん
            EOS
            EOT
        name => 'render text block',
    },
    {
        inp  => Tmpl-Block.new(:text('print "はじめましてお世界さん";')),
        outp => "print \"はじめましてお世界さん\";",
        name => 'render tmpl block',
    },
    {
        inp  => Text-Block.new(
            :text(' はじめまして お世界さん '),
            :trim-right,
        ),
        outp => q:to/EOT/,
            print q:to/EOS/.chomp;
             はじめまして お世界さん
            EOS
            EOT
        name => 'trim right',
    },
    {
        inp  => Text-Block.new(
            :text(' はじめまして お世界さん '),
            :trim-left,
        ),
        outp => q:to/EOT/,
            print q:to/EOS/.chomp;
            はじめまして お世界さん 
            EOS
            EOT
        name => 'trim left',
    },
    {
        inp  => Text-Block.new(
            :text(' はじめまして お世界さん '),
            :trim-right,
            :trim-left,
        ),
        outp => q:to/EOT/,
            print q:to/EOS/.chomp;
            はじめまして お世界さん
            EOS
            EOT
        name => 'trim both',
    },
];

plan @tests.elems;
is $_<inp>.render.raku, $_<outp>.raku, $_<name> for @tests;

done-testing;


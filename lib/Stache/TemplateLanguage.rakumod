
unit package Stache::TemplateLanguage:auth<github:littlebenlittle>:ver<0.0.0>;

use Stache::Base;

grammar Grammar {
    token TOP { <term>+ }
    token key {
        [ <.alpha> | <+[\d\-_]> ]+
    }
    token trim   { '-' | '<' | '>' | 'x' }
    token stache-open  { '{{' <trim>? }
    token stache-close { '}}' }
    token text {
        [
        | <-[{}]>
        | '}' <!after  '}'>
        | '{' <!before '{'>
        | '}' <!before '}'>
        | '{' <!after  '{'>
        ]+
    }
    token structure-block {
        || <for-block>
    }
    token for-close {
        <stache-open>
            <.ws> 'endfor'
            <.ws> 
        <.stache-close>
        $<ws-trailing>=<.ws>
    }
    token term {
        | <basic-block> { make $<basic-block>.made }
        | <for-block>   { make $<for-block>.made }
    }
    token for-block {
        <for-open>
            [<term> <!before <for-close>>]*
            <term>
        <for-close> {
            make -> *%ctx -->Str:D {
                my ($index, $nested-key) = $/<for-open>.made;
                my @contexts = $nested-key(|%ctx);
                .say for $/<term>.Str;
                @contexts.map(-> %ctx {
                    say %ctx;
                    $/<term>».made.map(-> &render { &render(|%ctx) }).join
                }).join
            }
        }
    }
    token basic-block {
        | <stache> { make $<stache>.made       }
        | <text>   { make -> | { $<text>.Str } }
    }
    token stache {
        <stache-open>
            <.ws> <nested-key>
            <.ws>
        <.stache-close> {
            my Callable:D $render = $<nested-key>.made;
            make $render;
        }
    }
    token nested-key {
        | <key> { make -> *%ctx -->Str:D { %ctx{$/<key>} } }
        | <key> '.' <nested-key> {
            make -> *%ctx -->Str:D {
                ($<nested-key>.made)(%ctx{$/<key>})
            }
        }
    }
    token for-open {
        <stache-open>
            <.ws> 'for'
            <.ws> <key>
            <.ws> ['in'|'←']
            <.ws> <nested-key>
            <.ws>
        <.stache-close>
        $<ws-trailing>=<.ws> {
            my Callable:D $nested-key = $/<nested-key>.made;
            make ($/<key>.Str, $nested-key)
        }
    }
}

our sub render(Str:D $tmpl, *%ctx) {
    class Actions {
        method TOP($/) {
            my Callable:D @terms = $/<term>».made;
            make @terms.map(-> Callable:D $render -->Str:D {
                my Str:D $res = $render(|%ctx).Str;
                $res
            });
        }
    }
    return Grammar.parse($tmpl, :actions(Actions)).made;
}



unit package Stache::TemplateLanguage:auth<github:littlebenlittle>:ver<0.0.0>;

use Stache::Base;

grammar Grammar is Stache::Base::Grammar {
    token TOP  { <term>+ }
    token term { <for-block> || [<text> | <stache>] }

    token key        { [ <.alpha> | <+[\d\-_]> ]+ }
    token nested-key { <key> | <key> '.' <nested-key> }

    token stache {
        <.stache-open>
            <.ws> <nested-key>
            <.ws>
        <.stache-close>
    }

    token for-block {
        <for-open>
            <.ws> <term>
            <.ws>
        <for-close>
    }
    token for-open   {
        <.stache-open>
            <.ws> 'for'
            <.ws> $<index>=<.key>
            <.ws> ['in'|'←']
            <.ws> $<indices>=<.key>
            <.ws>
        <.stache-close>
    }
    token for-close  {
        <.stache-open>
            <.ws> 'endfor'
            <.ws> 
        <.stache-close>
    }
}

our sub render(Str:D $tmpl, *%args) {
    class Actions is Stache::Base::Grammar::Actions {
        method TOP($/) {
            my @chunks = $/<term>».made;
            make @chunks.map(-> &f { &f(|%args) }).join
        }
        method term($/) {
            make -> *%ctx {
                my &fn = ($/<for-block> // $/<text> // $/<stache>).made;
                &fn(|%ctx);
            }
        }
        method for-block($/) {
            my %for = $/<for-open>.made;
            make -> | {
                %for<indices>.map(-> $val {
                    ($/<term>.made)(|%(%for<index> => $val))
                }).join;
            }
        }
        method for-open($/) {
            make %( index   => $/<index>.Str,
                    indices => %args{$/<indices>.Str} )
        }
        method stache($/) {
            make -> *%ctx { ($/<nested-key>.made)(|%ctx) }
        }
        method nested-key($/) {
            make -> *%ctx {
                my $render = ($/<key>.made)(|%ctx);
                $render ~= ($/<nested-key>.made)(|%ctx) if $/<nested-key>;
                $render;
            }
        }
        method key($/)  {
            make -> *%ctx { %ctx{$/.Str} }
        }
        method text($/) {
            make -> | { $/.Str }
        }
    }
    return Grammar.parse($tmpl, :actions(Actions)).made;
}


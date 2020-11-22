
unit package Stache::TemplateLanguage:auth<github:littlebenlittle>:ver<0.0.0>;

grammar Stache {
    token stache-open  { '{{' <trim>? }
    token stache-close { '}}' }
    token trim         { '-' | '<' | '>' }
    token text-char {
        | <-[{}\s]>
        | '}' <!after  '}'>
        | '{' <!before '{'>
        | '}' <!before '}'>
        | '{' <!after  '{'>
    }
    token text { [<.text-char>+]+ % \s+ }
}

grammar NestedKey is Stache {
    token key { [ <.alpha> | <+[\d\-_]> ]+ }
    token sep { '.' }
    token nested-key {
        | <key>
            {
                make -> *%ctx -->Any { %ctx{$/<key>} // "<! KEY-MISSING: $/<key> !>" }
            }
        | <key> <sep> <nested-key>
            {
                make -> *%ctx -->Any { ($<nested-key>.made)(|%ctx{$/<key>}) }
            }
    }
    token stache {
        $<ws-leading>=<.ws>
        <stache-open>
            <.ws> <nested-key>
            <.ws>
        <.stache-close>
        $<ws-trailing>=<.ws>
        {
            make -> *%ctx {
                my $s = ($<nested-key>.made)(|%ctx);
                do given $<stache-open><trim> {
                    when '-' {                 $s                  }
                    when '<' {                 $s ~ $<ws-trailing> }
                    when '>' { $<ws-leading> ~ $s                  }
                    default  { $<ws-leading> ~ $s ~ $<ws-trailing> }
                }
            }
        }
    }
}

grammar Grammar is NestedKey {
    token TOP { <term>+ }
    token term {
        | <stache>
          { make $<stache>.made    }
        | <for-block> 
          { make $<for-block>.made }
        | <text> [ <ws> <!before <stache-open>> | <ws> <?before <for-close>> ]
          { make -> | { $<text>.Str ~ $<ws>.Str } }
        | <text>
          { make -> | { $<text>.Str }  }
    }
    token for-block {
        <for-open>
            [<term> <!before <for-close>>]*
            <term>
        <for-close>
        {
            make -> *%ctx -->Str:D {
                my (
                    Str:D      $index,
                    Callable:D $nested-key,
                ) = $/<for-open>.made;
                my Array $keys = $nested-key(|%ctx);
                $keys.list.map(-> $key {
                    $/<term>».made.map(-> &render {
                        my %new-ctx = |%(
                            $index => $key,
                            |%ctx,
                        );
                        &render(|%new-ctx)
                    }).join
                }).join
            }
        }
    }
    token for-open {
        $<ws-leading>=<.ws>
        <stache-open>
            <.ws> 'for'
            <.ws> <key>
            <.ws> ['in'|'←']
            <.ws> <nested-key>
            <.ws>
        <.stache-close> {
            make (
                $/<key>.Str,
                $/<nested-key>.made,
            )
        }
        $<ws-trailing>=(\h* \n?)
    }
    token for-close {
        $<ws-leading>=<.ws>
        <stache-open>
            <.ws> 'endfor'
            <.ws> 
        <.stache-close>
        $<ws-trailing>=(\h* \n?)
    }
}

our sub render(Str:D $tmpl, *%ctx) {
    class Actions {
        method TOP($/) {
            my Callable:D @terms = $/<term>».made;
            make @terms.map(-> $render -->Str:D {
                $render(|%ctx);
            }).join;
        }
    }
    return Grammar.parse($tmpl, :actions(Actions)).made;
}


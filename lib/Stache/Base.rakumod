
unit package Stache::Base:auth<github:littlebenlittle>:ver<0.2.1>;

grammar Stache {
    token TOP { <term>+ }
    proto token term {*}
          token term:sym<text>   { <text> }
          token term:sym<stache> { <stache> }
    token text {
        [
        | <-[{]>
        | '{' <!before '{'>
        | '{' <!after  '{'>
        ]+
    }
    token variable-name { [ <.alpha> | <+[_\-\d]> ]+ }
    token trailing-ws   { [\h <?before \n>]* \n?     }
    token stache {
        '{{'   <.ws>
        <key>  <.ws>
        <op>?  <.ws>
        '}}' <trailing-ws>
    }
    proto token key {*}
          token key:sym<base> { <variable-name> ['.' <key:sym<base>>]? }
    token op  { '|' <.ws> <variable-name> <op>? }
}

grammar Structure is Stache {
    proto token structure {*}
    token term:sym<structure> { <structure> }
    token struct-block {
        <struct-open>  <trailing-ws>
          [<term> <!before <struct-close>>]* <term>
        <struct-close> <trailing-ws>
    }
    token struct-open  { '{{' <.ws> <{$*struct-kind}> <.ws> <struct-args> <.ws> '}}' }
    token struct-close {
        :my $fail = False;
        '{{' <.ws> 'end'
        [ <{$*struct-kind}> || \S* { $fail = True } ]
        <.ws> '}}'
        { die "mismatched structure close $/: line {$/.prematch.lines.elems + 1}" if $fail } 
    }
    token struct-args  { <key> }
    token key:sym<scoped> { '.' <key:sym<base>>? }
}

grammar For is Structure {
    token structure:sym<for>  { 
        :my $*struct-kind = 'for';
        <struct-block>
        { make $<struct-block>.made }
    }
}

grammar With is Structure {
    token structure:sym<with> {
        :my $*struct-kind = 'with';
        <struct-block>
        { make $<struct-block>.made }
    }
}

grammar Loop is For is With {
    class Actions {
        method TOP($/) { make -> *%ctx -->Str:D { $/<term>».made».(|%ctx).join } }
        method term:sym<text>      ($/) { make -> | { $/.Str }    }
        method term:sym<stache>    ($/) { make $/<stache>.made    }
        method term:sym<structure> ($/) { make $/<structure>.made }
        method stache($/) {
            make -> *%ctx { ($/<key>.made)(|%ctx).Str ~ $/<trailing-ws>.Str }
        }
        method key:sym<base>($/) {
            make -> *%ctx {
                if $/<key>.defined { ($/<key>.made)(|%ctx{$/<variable-name>}) }
                else               { %ctx{$/<variable-name>.Str} }
            }
        }
        method key:sym<scoped>($/) {
            make -> *%ctx {
                if $/<key>.defined { ($/<key>.made)(|$*topic) }
                else               { $*topic }
            }
        }
        method struct-block($/) {
            my $kind = $*struct-kind;
            make -> *%ctx -->Str:D {
                my $key = $/<struct-open><struct-args><key>;
                my $val = ($key.made)(|%ctx);
                do given $kind {
                    when 'with' {
                        do given $val {
                            my $*topic = $_;
                            when Hash { $/<term>».made».(|$_).join }
                            default { die "expected \"$key\" to be Hash, got {.^name}" }
                        }
                    }
                    when 'for' {
                        do given $val {
                            when List {
                                $_.map(-> $*topic {
                                    $/<term>».made».(|%ctx).join
                                }).join
                            }
                            default { die "expected \"$key\" to be List, got {.^name}" }
                        }
                    }
                    default { "huh? $_" }
                }
            }
        }
    }
}


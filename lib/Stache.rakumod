
unit package Stache:auth<github:littlebenlittle>:ver<0.1.0>;

use Stache::Base;

grammar Structure is Stache::Base::Grammar {
    proto token structure {*}
    token term:sym<structure> { <structure> }
    token struct-block {
        <struct-open>  <trailing-ws>
          [<term> <!before <struct-close>>]* <term>
        <struct-close> <trailing-ws>
    }
    token struct-open  { '{{' <.ws> <{$*struct-kind}> <.ws> <struct-args> <.ws> '}}' }
    token struct-close { '{{' <.ws> 'end' <{$*struct-kind}> <.ws> '}}' }
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

grammar Loops is For is With {
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

our sub render(Str:D $template, *%ctx) {
    my &render = Loops.subparse($template, :actions(Loops::Actions)).made;
    return &render(|%ctx)
}


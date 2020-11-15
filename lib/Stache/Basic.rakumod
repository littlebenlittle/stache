
unit package Stache::Basic;

class Chunk {
    has Str   $.text is required;
    has Chunk $.next-chunk;
    method render(-->Str:D) { $.text }
}

grammar Stache {
    our token text {
        [
        | <-[{}]>
        | '}' <!after  '}'>
        | '{' <!before '{'>
        | '}' <!before '}'>
        | '{' <!after  '{'>
        ]+
    }
    token TOP    { <stache> || <body> || $<unknown>=(.*) }
    token stache { '{{' <text> '}}' <body>?  }
    token body   { <text> <stache>? }
    class Actions {
        method TOP($/) {
            my $chunk;
            $chunk = $/<body>.made   if $/<body>.defined;
            $chunk = $/<stache>.made if $/<stache>.defined;
            my @chunks = ();
            while $chunk.defined {
                @chunks.push($chunk);
                NEXT { $chunk .= next-chunk }
            }
            make @chunks».render.join;
        }
        method body($/)   {...}
        method stache($/) {...}
    }
}

sub new-stache(:&text, :&interp) is export {
    return -> Str:D $raw, |c {
        grammar G is Stache {
            class Actions is Stache::Actions {
                method body($/) {
                    my $raw = $/<text>.Str;
                    make Chunk.new(
                        text       => &text($raw, |c),
                        next-chunk => $/<stache>.made,
                    );
                }
                method stache($/) {
                    make Chunk.new(
                        text       => &interp($/<text>.Str, |c),
                        next-chunk => $/<body>.made,
                    );
                }
            }
            method parse($target, Mu :$actions = Actions) {
                callwith($target, :actions($actions));
            }
        }
        G.parse($raw).made;
    }
}


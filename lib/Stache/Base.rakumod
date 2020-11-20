
unit package Stache::Base:auth<github:littlebenlittle>:ver<0.1.0>;

class Chunk {
    has Str   $.render is required;
    has Chunk $.next;
    has Chunk $.prev;
    has %.context;
}

grammar Grammar {
    token text {
        [
        | <-[{}]>
        | '}' <!after  '}'>
        | '{' <!before '{'>
        | '}' <!before '}'>
        | '{' <!after  '{'>
        ]+
    }
    token stache-open  { '{{' }
    token stache-close { '}}' }
    token TOP    { <stache> || <body> || $<unknown>=(.*) }
    token stache { <.stache-open> <text> <.stache-close> }
    class Actions {
        method TOP($/) {
            my $chunk = ($/<body> // $/<stache>).made;
            my @chunks = ();
            while $chunk.defined {
                @chunks.push($chunk);
                NEXT { $chunk .= next }
            }
            make @chunks».render.join;
        }
        method body($/)   {...}
        method stache($/) {...}
    }
}


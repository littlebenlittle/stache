
unit package Stache::Base:auth<github:littlebenlittle>:ver<0.1.0>;

class Chunk {
    has Str   $.render is required;
    has Chunk $.next;
    has Chunk $.prev;
    has %.context;
}

grammar Grammar {
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


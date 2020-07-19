
unit package Stache:ver<0.0.0>;

enum trim is export(:Internals) <left right both none>;

class Block is export(:Internals) {
    has Str   $.body    is required;
    has trim  $.trim    is required;
    has Block $.next-block;
    has Block $.prev-block is rw;
    method render(-->Str:D) {*}
}

class Raw-Block is Block is export(:Internals) {
    method render {
        return self.body;
    }
}

class Raku-Block is Block is export(:Internals) {
    method render {
        my $cmd = « $*EXECUTABLE -e "'{self.body}'" »;
        my $proc = shell $cmd, :out;
        return $proc.out.slurp(:close).chomp;
    }
}

grammar Grammar is export(:Internals) {
    token TOP    { <body> | <stache> }
    token body   { <text> <stache>? }
    token stache { '{{' <trim-tag>? <text> '}}' <body>?  }
    token text     { <-[{}]>* }
    token trim-tag { <+[<>-]> }
    class Actions {
        method TOP($/) {
            my $block = $/<body>.defined
                     ?? $/<body>.made
                     !! $/<stache>.made;
            my $doc = '';
            while $block.defined {
                $doc   ~= $block.render;
                $block .= next-block;
            }
            make $doc;
        }
        method body($/) {
            make Raw-Block.new(
                body       => $/<text>.Str,
                trim       => none,
                next-block => $/<stache>.defined ?? $/<stache>.made !! Nil,
            );
        }
        method stache($/) {
            my $trim-type;
            given $/<trim-tag> {
                when Nil { $trim-type = none  }
                when '<' { $trim-type = left   }
                when '>' { $trim-type = right  }
                when '-' { $trim-type = both  }
                default  { fail "unrecognized trim tag: {$/<trim-tag>}" }
            }
            my $next-block = $/<body>.made if $/<body>.defined;
            my $block = Raku-Block.new(
                body       => $/<text>.trim,
                trim       => $trim-type,
                next-block => $next-block,
            );
            $next-block.prev-block = $block;
            make $block;
        }
    }
    method parse($target, Mu :$actions = Actions, |c) {
        callwith($target, :actions($actions), |c);
    }
}

sub MAIN(
    IO() $file,
    :$debug = False,
) is export(:MAIN) {
    CATCH { fail "Could not render template: $!" }
    say Grammar.parse($file.slurp.trim).made;
}


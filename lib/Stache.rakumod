
unit package Stache:ver<0.0.0>;

enum trim is export(:Internals) <pre post both none>;

sub process-raku(Str:D $body) is export(:Internals) {
    my $cmd = « $*EXECUTABLE -e "'$body'" »;
    my $proc = shell $cmd, :out;
    return $proc.out.slurp(:close).chomp;
}

class Block is export(:Internals) {
    has Str   $.body is required;
    has trim  $.trim is required;
    has Str   $.context is required;
    has Block $.next-block;
    method render {
        my $render = '';
        given self.context {
            when 'raw'  { $render = self.body }
            when 'raku' { $render = process-raku(self.body) }
        }
        given self.trim {
            my &terminal-whitespace = /' '+$/;
            when post { $render = $render.subst: &terminal-whitespace, '' }
            when both { $render = $render.subst: &terminal-whitespace, ''}
            default   { $render = $render }
        }
        if defined self.next-block {
            $render = $render ~ self.next-block.render;
        }
        return $render;
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
            my $doc = '';
            my $block = $/<body>.defined
                     ?? $/<body>.made
                     !! $/<stache>.made;
            make $block.render;
        }
        method body($/) {
            make Block.new(
                body       => $/<text>.Str,
                trim       => none,
                context    => 'raw',
                next-block => $/<stache>.defined ?? $/<stache>.made !! Nil,
            );
        }
        method stache($/) {
            my $trim-type;
            given $/<trim-tag> {
                when Nil { $trim-type = none  }
                when '<' { $trim-type = pre   }
                when '>' { $trim-type = post  }
                when '-' { $trim-type = both  }
                default  { fail "unrecognized trim tag: {$/<trim-tag>}" }
            }
            make Block.new(
                body       => ($/<text>.trim // '').Str,
                trim       => $trim-type,
                context    => 'raku',
                next-block => $/<body>.defined ?? $/<body>.made !! Nil,
            );
        }
    }
    method parse($target, Mu :$actions = Actions, |c) {
        # say "parsing q:to/EOF/\n$target\nEOF";
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


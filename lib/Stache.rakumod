
unit package Stache:auth<ben.little@fruition.net>:ver<0.0.0>;

enum trim is export(:Internals) <left right both none>;

class Block {
    has Str   $.body is required;
    has trim  $.trim-tag is required;
    has Bool  $.trim-left  is rw = False;
    has Bool  $.trim-right is rw = False;
    has $.next-block;
    method set-trim-left  { $.trim-left  = True }
    method set-trim-right { $.trim-right = True }
    method render(-->Str:D) {...}
}

class Body-Block is Block is export(:Internals) {
    method render(-->Str:D) {
        my $body = self.body;
        $body .= subst(/^<ws>/,'') if self.trim-left;
        $body .= subst(/<ws>$/,'') if self.trim-right;
        return qq:to/EOF/;
        print q:to/EOS/.chomp;
        $body
        EOS
        EOF
    }
}

class Tmpl-Block is Block is export(:Internals) {
    method render(-->Str:D) { return self.body.trim ~ ";\n" ; }
}

grammar Grammar is export(:Internals) {
    token TOP    { <body> | <stache> }
    token body   { <text> <stache>? }
    token stache { '{{' <trim-tag>? <text> '}}' <body>?  }
    token text     { <-[{}]>* }
    token trim-tag { <+[<>-]> }
    class Actions {
        method TOP($/) {
            my $block;
            our $*state = {};
            $block = $/<body>.made   if $/<body>.defined;
            $block = $/<stache>.made if $/<stache>.defined;
            my @blocks = ();
            my $*prev-block;
            my $next-block-should-be-trimmed = False;
            my $this-block-should-be-trimmed = False;
            while $block.defined {
                $block.set-trim-left if $this-block-should-be-trimmed;
                if $block.trim-tag ∈ (right,both) {
                    $next-block-should-be-trimmed = True;
                }
                if $*prev-block.defined and $block.trim-tag ∈ (left,both) {
                    $*prev-block.set-trim-right;
                }
                @blocks.push($block);
                NEXT {
                    $*prev-block = $block;
                    $block .= next-block;
                    $this-block-should-be-trimmed = $next-block-should-be-trimmed;
                }
            }
            make @blocks».render.join;
        }
        method body($/) {
            make Body-Block.new(
                body       => $/<text>.Str,
                trim-tag   => none,
                next-block => $/<stache>.made,
            );
        }
        method stache($/) {
            my $block = Tmpl-Block.new(
                body     => $/<text>.Str,
                trim-tag =>
                    $/<trim-tag>.defined ?? {
                        '<' => left,
                        '>' => right,
                        '-' => both,
                    }{$/<trim-tag>} !! none,
                next-block => $/<body>.made,
            );
            make $block;
        }
    }
    method parse($target, Mu :$actions = Actions, |c) {
        our $*block = Nil;
        callwith($target, :actions($actions), |c);
    }
}

sub MAIN(
    IO() $file,
    :$debug = False,
) is export(:MAIN) {
    CATCH { fail "Could not render template: $!" }
    try say render-template: $file.slurp.trim;
}

sub render-template(Str:D $template) is export(:Internals) {
    my $script = Grammar.parse($template).made;
    return .out.slurp(:close).chomp given shell "$*EXECUTABLE -e '$script'", :out;
}


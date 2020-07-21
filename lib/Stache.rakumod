
unit package Stache:auth<ben.little@fruition.net>:ver<0.0.0>;

enum trim is export(:Internals) <left right both none>;

class Block is export(:Internals) {
    has Str   $.body is required;
    has trim  $.trim-tag is required;
    has Bool  $!trim-left  = False;
    has Bool  $!trim-right = False;
    has $.next-block;
    method render(-->Str:D) {
        my $doc = self.body;
        $doc .= subst(/^<ws>/,'') if $!trim-left;
        $doc .= subst(/<ws>$/,'') if $!trim-right;
        return $doc;
    }
    method set-trim-left  { $!trim-left  = True }
    method set-trim-right { $!trim-right = True }
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
            $block = $/<body>.made   if $/<body>.defined;
            $block = $/<stache>.made if $/<stache>.defined;
            my @blocks = ();
            my $*prev-block;
            my $next-block-should-be-trimmed = False;
            while $block.defined {
                $block.set-trim-left if $next-block-should-be-trimmed;
                if $block.trim-tag ∈ (right,both) {
                    $next-block-should-be-trimmed = True;
                }
                if $*prev-block.defined and $block.trim-tag ∈ (left,both) {
                    $*prev-block.set-trim-right;
                }
                @blocks.push($block);
                $*prev-block = $block;
                $block .= next-block;
            }
            my $doc ~= .render for @blocks;
            make $doc;
        }
        method body($/) {
            make Block.new(
                body       => $/<text>.Str,
                trim-tag   => none,
                next-block => $/<stache>.made,
            );
        }
        method stache($/) {
            my $cmd  = « $*EXECUTABLE -e "'{$/<text>}'" »;
            my $proc = shell $cmd, :out;
            my $block = Block.new(
                body     => $proc.out.slurp(:close).chomp,
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
    say Grammar.parse($file.slurp.trim).made;
}



unit package Stache:auth<ben.little@fruition.net>:ver<0.0.0>;

enum trim is export(:Internals) <left right both none>;

class Block {
    has Str   $.text is required;
    has trim  $.trim-tag = none;
    has Bool  $.should-trim-left  is rw = False;
    has Bool  $.should-trim-right is rw = False;
    has $.next-block;
    method render(-->Str:D) {...}
}

class Text-Block is Block is export(:Internals) {
    method render(-->Str:D) {
        return '' if self.text ~~ / ^<ws>$ /;
        my $text = self.text;
        $text .= subst(/^<ws>/,'') if self.should-trim-left;
        $text .= subst(/<ws>$/,'') if self.should-trim-right;
        return qq:to/EOF/;
        print q:to/EOS/.chomp;
        $text
        EOS
        EOF
    }
}

class Tmpl-Block is Block is export(:Internals) {
    method render(-->Str:D) { return self.text.trim }
}

grammar Grammar is export(:Internals) {
    our token trim-tag { <+[<>-]> }
    our token text {
        [
        | <-[{}]>
        | '}' <!before '}'>
        | '{' <!after  '{'>
        ]*
    }
    token TOP    { <body> | <stache> || $<unknown>=(.*) }
    token stache { '{{' <trim-tag>? <text> '}}' <body>?  }
    token body   { <text> <stache>? }
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
                $block.should-trim-left = True if $this-block-should-be-trimmed;
                if $block.trim-tag ∈ (right,both) {
                    $next-block-should-be-trimmed = True;
                }
                if $*prev-block.defined and $block.trim-tag ∈ (left,both) {
                    $*prev-block.should-trim-right = True;
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
            make Text-Block.new(
                text       => $/<text>.Str,
                trim-tag   => none,
                next-block => $/<stache>.made,
            );
        }
        method stache($/) {
            my $block = Tmpl-Block.new(
                text     => $/<text>.Str,
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
    IO() $file, #| path to the template to render
    :$I,        #| include path
    :$debug = False,
) is export(:MAIN) {
    say render-template($file.slurp.trim, :I($I));
}

sub render-template(
    Str:D $tmpl,       #| the template to render
    Bool :$to-script,  #| return the script rather than the document
    :$I,               #| include path
) is export(:Internals) {
    my IO::Path $fh;
    ENTER {
        my $id = sprintf '%d%d%d%d', (0..9).pick: 4;
        $fh = $*TMPDIR.add("stache-$id").IO;
    }
    LEAVE { $fh.unlink if $fh.defined; }
    my $script = Grammar.parse($tmpl).made;
    fail "could not parse template" unless $script;
    return $script if $to-script;
    my @flag-strings = ();
    $fh.spurt($script);
    @flag-strings.push("-I $I") if $I;
    my $proc = run « $*EXECUTABLE @flag-strings[] $fh », :out, :err;
    my $out = $proc.out.slurp(:close).chomp;
    my $err = $proc.err.slurp(:close).chomp;
    return $out;
}


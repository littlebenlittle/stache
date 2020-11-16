
unit package Stache::App:auth<github:littlebenlittle>:ver<0.1.0>;

use Stache::Base;

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

grammar Grammar is Stache::Base::Grammar is export(:Internals) {
	class Actions is Stache::Base::Grammar::Actions {
        method TOP($/) {
            my $block;
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
            make @blocks».render.join: "\n";
        }
        method body($/) {
            make Text-Block.new(
                text       => $/<text>.Str,
                trim-tag   => none,
                next-block => $/<stache>.made,
            );
        }
        method stache($/) {
			my $raw = $/<text>.Str;
            grammar Interpolation {
                token TOP { <trim-tag>? <text> }
				token text { .* }
                token trim-tag { <+[<>-]> }
                class Actions {
					method TOP($/) {
						given $/<trim-tag> {
							when '<' { make (left,  $/<text>.Str) }
							when '>' { make (right, $/<text>.Str) }
							when '-' { make (both,  $/<text>.Str) }
							default  { make (none,  $/<text>.Str) }
						}
					}
				}
                method parse($target, Mu :$actions = Actions) {
                    callwith($target, :actions($actions));
                }
            }
            my ($trim-tag, $outp) = Interpolation.parse($raw.trim).made;
            die "couldn't parse «$raw»" unless $outp;
            make Tmpl-Block.new(
                text       => $outp,
                trim-tag   => $trim-tag,
                next-block => $/<body>.made,
            );
        }
    }
    method parse($target, Mu :$actions = Actions, |c) {
        our $*block = Nil;
        callwith($target, :actions($actions), |c);
    }
}

sub MAIN(
    IO() $file,       #| path to the template to render
    :$I,              #| include path
    :$script = False, #| render the script rather than executing it
) is export(:MAIN) {
    say render-template($file.slurp.trim, :I($I), :to-script($script));
}

sub render-template(
    Str:D $tmpl,       #| the template to render
    Any  :$topic,      #| object passed as topic to the template
    Str  :$I,          #| include path
    Bool :$to-script,  #| render the script rather than executing it
) is export(:Internals, :render-template) {
    my IO::Path $fh;
    ENTER {
        unless $to-script {
            my $id = sprintf '%d%d%d%d', (0..9).pick: 4;
            $fh = $*TMPDIR.add("stache-$id").IO;
        }
    }
    LEAVE { $fh.unlink if $fh.defined; }
	my $match = Grammar.parse($tmpl);
	die "could not parse template" unless $match;
    my $script = $match.made;
    return $script if $to-script;
    $fh.spurt($script);
    my @flag-strings = ();
    @flag-strings.push("-I $I") if $I;
    my $proc = run « $*EXECUTABLE @flag-strings[] $fh », :out, :err;
    my $out = $proc.out.slurp(:close).chomp;
    my $err = $proc.err.slurp(:close).chomp;
    fail $err if $proc.exitcode != 0;
    return $out;
}


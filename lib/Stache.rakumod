
unit package Stache:auth<github:littlebenlittle>:ver<0.1.0>;

use Stache::Base;

our sub new-renderer(:&text, :&interp) {
    return -> Str:D $raw, |c {
        grammar G is Stache::Base::Grammar {
            class Actions is Stache::Base::Grammar::Actions {
                method body($/) {
                    my $raw = $/<text>.Str;
                    make Stache::Base::Chunk.new(
                        text       => &text($raw, |c),
                        next-chunk => $/<stache>.made,
                    );
                }
                method stache($/) {
                    make Stache::Base::Chunk.new(
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


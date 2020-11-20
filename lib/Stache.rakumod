
unit package Stache:auth<github:littlebenlittle>:ver<0.1.0>;

use Stache::Base;

our sub new-renderer(:&body, :&stache) {
    return -> Str:D $raw, *%args {
        class Actions is Stache::Base::Grammar::Actions {
            method body($/) {
                make Stache::Base::Chunk.new(
                    render => &body($/<text>.Str, |%args),
                    next   => $/<stache>.made,
                );
            }
            method stache($/) {
                make Stache::Base::Chunk.new(
                    render => &stache($/<text>.Str, |%args),
                    next   => $/<body>.made,
                );
            }
        }
        Stache::Base::Grammar.parse($raw, :actions(Actions)).made;
    }
}


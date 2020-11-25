
unit package Stache:auth<github:littlebenlittle>:ver<0.1.0>;

use Stache::Base;

our sub render(Str:D $template, *%ctx) {
    my &render = Stache::Base::Loop.subparse(
        $template,
        :actions(Stache::Base::Loop::Actions)
    ).made;
    return &render(|%ctx)
}



unit package Stache:auth<github:littlebenlittle>:ver<0.2.0>;

use Stache::Base;
use YAMLish;

our sub render(Str:D $template, *%ctx) {
    my &render = Stache::Base::Loop.subparse(
        $template,
        :actions(Stache::Base::Loop::Actions)
    ).made;
    return &render(|%ctx)
}

sub MAIN(
    IO() $template; #= path to template
    IO() :$values;  #= path to yaml-serialized values
) is export(:MAIN) {
    my $text = $template.slurp;
    my %ctx  = load-yaml $values.slurp;
    say render($text, |%ctx);
}

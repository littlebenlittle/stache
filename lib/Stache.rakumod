
unit package Stache:auth<github:littlebenlittle>:ver<0.2.1>;

use Stache::Base;
use YAMLish;

our proto sub render(|) {*}

multi sub render(Str:D $template, *%ctx) {
    my &render = Stache::Base::Loop.subparse(
        $template,
        :actions(Stache::Base::Loop::Actions)
    ).made;
    die "could not parse template" unless &render;
    return &render(|%ctx)
}

multi sub render(Str:D $template, IO() $values) {
    my %ctx  = load-yaml $values.slurp;
    return callwith($template, |%ctx)
}

sub MAIN(
    IO()  $template; #= path to template
    IO() :$values;   #= path to yaml-serialized values
) is export(:MAIN) {
    my $text = $template.slurp;
    our $*file = $values.path;
    say render($text, $values);
}


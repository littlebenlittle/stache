
unit package Stache:auth<github:littlebenlittle>:ver<0.2.1>;

use Stache::Base;
use YAMLish;

#| render a template
our sub render(Str:D $template, *%ctx) {
    my &render = Stache::Base::Loop.subparse(
        $template,
        :actions(Stache::Base::Loop::Actions)
    ).made;
    return &render(|%ctx)
}

#| copy a directory from src to dest, rendering any templates
our sub render-dir(IO() $src, IO() $dest, *%ctx) {
    if $dest.e {
        die "$dest exists and is not an empty directory"
          unless $dest.d and $dest.dir.elems == 0;
    } else { mkdir $dest }
    for $src.dir {
        my $target = $dest.add($_.basename);
        if    $_.d { render-dir $_, $target, |%ctx }
        elsif $_.f { $target.spurt: render $_.slurp, |%ctx }
        else { note "neither file nor directory: $src, skipping" }
    }
}

sub MAIN(
    IO() $template; #= path to template
    IO() :$values;  #= path to yaml-serialized values
) is export(:MAIN) {
    my $text = $template.slurp;
    my %ctx  = load-yaml $values.slurp;
    say render($text, |%ctx);
}

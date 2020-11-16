
unit package Stache::Renderer:auth<github:littlebenlittle>:ver<0.1.0>;

use Stache;

our &basic = Stache::new-renderer(
    text   => -> $raw, |c { $raw },
    interp => -> $raw, |c {
        grammar Interpolation {
            token TOP { [ <alnum> || <+[-_]> ]+ }
            class Actions {
                method TOP($/) {
                    my $s = $/.Str;
                    my $found = False;
                    for c.hash.keys -> $key {
                        if $key eq $s {
                            make c.hash{$key};
                            $found = True;
                        }
                    }
                    make "ERROR: {$s}" if not $found;
                }
            }
            method parse($target, Mu :$actions = Actions) {
                callwith($target, :actions($actions));
            }
        }
        my $outp = Interpolation.parse($raw.trim).made;
        die "couldn't parse «$raw»" unless $outp;
        $outp;
    },
);

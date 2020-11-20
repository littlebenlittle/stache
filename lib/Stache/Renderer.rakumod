
unit package Stache::Renderer:auth<github:littlebenlittle>:ver<0.1.0>;

use Stache;

our &basic = Stache::new-renderer(
    body   => -> $raw, *%args { $raw },
    stache => -> $raw, *%args {
        my grammar Interpolation {
            token TOP { [ <alnum> || <+[-_]> ]+ }
        }
        my class Actions {
            method TOP($/) {
                my $s = $/.Str;
                my $found = False;
                for %args.keys -> $key {
                    if $key eq $s {
                        make %args{$key};
                        $found = True;
                    }
                }
                make "ERROR: {$s}" if not $found;
            }
        }
        my $outp = Interpolation.parse($raw.trim, :actions(Actions)).made;
        die "couldn't parse «$raw»" unless $outp;
        $outp;
    },
);

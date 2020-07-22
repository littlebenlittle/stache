
use Test;

my @skip = ('block', 'basic');

sub MAIN(IO() :$I) {
    CATCH { fail "Test harness failed to execute: $!" }
    my @t-files = $?FILE.IO.dirname.IO.dir.list.grep: * ~~ /'.t'$/;
    my @flag-strings = ();
    @flag-strings.push("-I $I") if $I;
    my $results = {};
    race for @t-files -> $filename {
        next if $filename ~~ /$_ / for @skip;
        $results{$filename} =
            run « $*EXECUTABLE @flag-strings[] $filename », :out, :err;
    }
    my $exitcode = 0;
    my $out = '';
    my $err = '';
    for @t-files.sort -> $filename {
        my $proc = $results{$filename};
        $exitcode = 1 if $proc.exitcode != 0;
        $out ~= $proc.out.slurp(:close);
        $err ~= $proc.err.slurp(:close);
    }
    say  $out;
    note $err;
    exit $exitcode;
}


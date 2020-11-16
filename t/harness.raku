
sub MAIN(IO() :$I) {
    my @t-files = $?FILE.IO.dirname.IO.dir.list.grep: * ~~ /'.t'$/;
    my @flag-strings = ();
    @flag-strings.push("-I $I") if $I;
    my $bufs = {};
    my @pass = ();
    my @fail = ();
    race for @t-files -> $filename {
        my @cmd = « $*EXECUTABLE @flag-strings[] $filename »;
        my $proc = Proc::Async.new: @cmd, :out, :err;
        my $buf := $bufs{$filename};
        $buf = '';
        my $signals = signal(SIGHUP).merge(signal(SIGINT)).merge(signal(SIGTERM));
        react {
            whenever $proc.stdout.lines { $buf ~= "OUT: $_\n" }
            whenever $proc.stderr.lines { $buf ~= "ERR: $_\n" }
            whenever $signals { $proc.kill: $_ }
            whenever $proc.start {
                @pass.push: $filename if .exitcode == 0;
                @fail.push: $filename if .exitcode != 0;
                done
            }
        }
    }
    for @pass.sort -> $filename {
        note "# PASS {$filename}\n";
        note $bufs{$filename};
    }
    for @fail.sort -> $filename {
        note "# FAIL {$filename}\n";
        note $bufs{$filename};
    }
    my $pass = @fail.elems == 0;
    note "### ALL TESTS PASS ###" if $pass;
    exit $pass ?? 1 !! 0;
}



sub MAIN(IO() :$I) {
    my @t-files = $?FILE.IO.dirname.IO.dir.list.grep: * ~~ /'.t'$/;
    my @flag-strings = ();
    @flag-strings.push("-I $I") if $I;
    my $bufs = {};
    my $exitcode = 0;
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
                $exitcode = 1 if .exitcode != 0;
                done
            }
        }
    }
    for @t-files.sort -> $filename {
        note "# {$filename}\n";
        note $bufs{$filename};
    }
    note "### ALL TESTS PASS ###" if $exitcode == 0;
    exit $exitcode;
}


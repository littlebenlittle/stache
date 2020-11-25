use v6;

use Test;
use Stache;
use FileSystem::Helpers;

plan 5;

FileSystem::Helpers::temp-dir {
    my $dirA = $*tmpdir.add('A');
    my $dirB = $*tmpdir.add('B');
    $dirA.mkdir;
    $dirB.mkdir;
    $dirB.add('file.txt').spurt: 'some text';
    my $exception-payload = '';
    do {
        Stache::render-dir($dirA, $dirB);
        CATCH {
            when X::AdHoc { $exception-payload = .payload }
            default       { .rethrow }
        }
    }
    cmp-ok
        $exception-payload,
        '~~',
        rx:s/exists and is not an empty directory/,
        'cannot overrwrite existing non-empty directory';

    my $dirC = $*tmpdir.add('C');
    my $subA = $dirA.add('sub');
    mkdir $subA;
    my $tmpl   = $dirA.add('file.txt');
    my $target = $dirC.add('file.txt');
    $tmpl.spurt: '{{ stache }}';
    Stache::render-dir($dirA, $dirC, stache => 'text');
    ok $dirC.d, 'created directory';
    ok $target.f, 'created file';
    cmp-ok
        $target.slurp,
        '~~',
        rx:s/text/,
        'rendered template';
    ok $dirC.add('sub').d, 'subdirectory created';
};

done-testing;


use v6;

use Test;

use Stache::TemplateLanguage;

class Unit {
    has $.template;
    has %.ctx;
    has $.expects;
    has $.name;
}

my @units = [
    Unit.new(
        name => 'trim ws right',
        template => q:to/EOT/,
        X {{> A }} Y  {{> B }} Z
        EOT
        ctx => %(
            A => 'A',
            B => 'B',
        ),
        expects => q:to/EOT/,
        X AY  BZ
        EOT
    ),
    Unit.new(
        name => 'trim ws left and both',
        template => q:to/EOT/,
        X {{< A }} Y  {{- B }} Z
        EOT
        ctx => %(
            A => 'A',
            B => 'B',
        ),
        expects => q:to/EOT/,
        XA YBZ
        EOT
    ),
    Unit.new(
        name => 'trim across newlines',
        template => q:to/EOT/,
        X {{- A }}
        Y {{- B }}
        Z
        EOT
        ctx => %(
            A => 'A',
            B => 'B',
        ),
        expects => q:to/EOT/,
        XAYBZ
        EOT
    ),
    Unit.new(
        name => 'for block with string',
        template => q:to/EOT/,
        {{ for f in fruits }}
          {{ f }} is fruit
        {{ endfor }}
        EOT
        ctx => %(
            fruits => [
                'apricot',
                'banana',
                'cherry',
            ],
        ),
        expects => q:to/EOT/,
          apricot is fruit
          banana is fruit
          cherry is fruit
        EOT
    ),
    Unit.new(
        name => 'for block with nested object',
        template => q:to/EOT/,
        {{ for f in fruits }}
          {{ f.name }} is {{ f.quality }}
        {{ endfor }}
        EOT
        ctx => %(
            fruits => [
                %( name => 'apricot', quality => 'lo' ),
                %( name => 'banana',  quality => 'md' ),
                %( name => 'cherry',  quality => 'hi' ),
            ],
        ),
        expects => q:to/EOT/,
          apricot is lo
          banana is md
          cherry is hi
        EOT
    ),
];

plan @units.elems;

is  Stache::TemplateLanguage::render(.template, |.ctx),
    .expects,
    .name
    for @units;#[3..*];

done-testing;


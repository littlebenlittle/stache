
unit package Stache::Base:auth<github:littlebenlittle>:ver<0.1.0>;

grammar Grammar {
    token TOP { <term>+ }
    proto token term {*}
          token term:sym<text>   { <text> }
          token term:sym<stache> { <stache> }
    token text {
        [
        | <-[{]>
        | '{' <!before '{'>
        | '{' <!after  '{'>
        ]+
    }
    token variable-name { [ <.alpha> | <+[_\-\d]> ]+ }
    token trailing-ws   { [\h <?before \n>]* \n?     }
    token stache {
        '{{'   <.ws>
        <key>  <.ws>
        <op>?  <.ws>
        '}}' <trailing-ws>
    }
    proto token key {*}
          token key:sym<base> { <variable-name> ['.' <key:sym<base>>]? }
    token op  { '|' <.ws> <variable-name> <op>? }
}

